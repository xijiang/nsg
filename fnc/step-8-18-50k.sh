##############################################################################
# This script is to test the imputation rates for various panels
# Data:
#  1. Full panel: 606k, 828ID
#  2. 18k \in 50k \in 606k
#  3. 8k are majorly \in 18k
# Method:
#  1. Extract 18k, & 50k results of the 345 ID from genotypes of  828ID
#  2. impute and compare
##############################################################################
# ToDo:
# 1) group the files into different directories
#    as there are too many files in this working directory
##############################################################################

#!/usr/bin/env bash

prepare-a-working-directory(){
    ############################################################
    # Create a working directory
    work=$base/work/step--8k-18k-50k-hd
    local low='l8k l18k l50k l8k-18k l8k-18k-50k l18k-50k'
    local high='h18k h50k hhd 828'
    local imp='8k-18k 8k-50k 8k-hd 18k-50k 18k-hd 50k-hd 8k-18k-50k 8k-18k-50k-hd 18k-50k-hd'
    local other='tmp err mapid'

    for dir in $low $high $imp $other; do
	mkdir -p $work/$dir
    done

    cd $work

    # soft link the genotypes here
    for i in $G600K; do
	ln -sf $genotypes/$i .
    done
}


make-id-maps(){
    echo collect ID
    grep -v ^# $genotypes/genotyped.id |
	gawk '{if(length($5)>5) print $5, $2}' >mapid/828.id

    grep -v ^# $genotypes/genotyped.id |
	gawk '{if(length($5)>5 && length($4)<5) print $5, $2}' >mapid/483.id

    grep -v ^# $genotypes/genotyped.id |
	gawk '{if(length($5)>5 && length($4)>5) print $5, $2}' >mapid/345.id
    
    echo Make maps
    tail -n+2 $maps/current.map |
    	gawk '{print $13, $11, $12}' >mapid/hd.map

    cat mapid/hd.map |
	$bin/subMap $maps/8k.snp     >mapid/8k.map
    
    cat mapid/hd.map |
	$bin/subMap $maps/18k.snp    >mapid/18k.map

    cat mapid/hd.map |
	$bin/subMap $maps/50k.snp    >mapid/50k.map
}
    

collect-828-hd-genotypes(){
    # It is more accurate to use genotypes of more ID.
    # Hence the results here will serve a general reference for imputation rates
    echo Create beagle files
    $bin/mrg2bgl mapid/{828.id,hd.map} $G600K

    for chr in {26..1}; do
	java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
	    gzip -c >tmp.vcf.gz
	
	java -jar $bin/beagle.jar \
	     gt=tmp.vcf.gz \
	     ne=$ne \
	     out=828/$chr
    done
}


collect-step-genotypes(){
    # step genotypes of 483 ID, with prefix 'h'
    for panel in 18k 50k hd; do
	echo genotypes of 483 ID with $panel panel
	$bin/mrg2bgl mapid/483.id mapid/$panel.map $G600K

	for chr in {26..1}; do
	    java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
		gzip -c >h$panel/$chr.vcf.gz
	done
    done

    # step genotypes of 345 ID, with prefix 'l'
    for panel in 8k 18k 50k; do
	echo genotypes of 345 ID with $panel panel
	$bin/mrg2bgl mapid/345.id mapid/$panel.map $G600K

	for chr in {26..1}; do
	    java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
		gzip -c >l$panel/$chr.vcf.gz
	done
    done
}


mrg-n-imp(){
    local low=$1		# $1: of lower density map
    local hgh=$2		# $2: of higher density map
    local chr=$3		# $3: chr
    
    $bin/ljvcf <(zcat h$hgh/$chr.vcf.gz) <(zcat l$low/$chr.vcf.gz) |
	gzip -c >tmp.vcf.gz

    java -jar $bin/beagle.jar \
	 gt=tmp.vcf.gz \
	 ne=$ne \
	 out=$low-$hgh/$chr
}


step-merge-n-impute(){
    for chr in {26..1}; do
	mrg-n-imp  8k 18k $chr
	mrg-n-imp  8k 50k $chr
	mrg-n-imp  8k  hd $chr
	mrg-n-imp 18k 50k $chr
	mrg-n-imp 18k  hd $chr
	mrg-n-imp 50k  hd $chr

	# 8k->18k->50k->hd
	zcat 8k-18k/$chr.vcf.gz |
	    $bin/subid mapid/345.id |
	    gzip -c >l8k-18k/$chr.vcf.gz
	mrg-n-imp 8k-18k 50k $chr

	zcat 8k-18k-50k/$chr.vcf.gz |
	    $bin/subid mapid/345.id |
	    gzip -c >l8k-18k-50k/$chr.vcf.gz
	mrg-n-imp 8k-18k-50k hd $chr

	# 18k->50k->hd
	zcat 18k-50k/$chr.vcf.gz |
	    $bin/subid mapid/345.id |
	    gzip -c >l18k-50k/$chr.vcf.gz
	mrg-n-imp 18k-50k hd $chr
    done
}


get-snp-fra(){
    # print SNP names from a VCF file
    zcat $1 |
	grep -v ^# |
	gawk '{print $3}' >$2
}


get-snp-with-count-num(){
    # print SNP in ${@:3} who appeared $1 times into $2
    # ${@:3} means the arguments start from 3
    cat ${@:3} |
	sort |
	uniq -c |
	gawk -v cnt=$1 '{if($1==cnt) print $2}' >$2
}


imputation-rates(){
    fra=$1
    to=$2
    chr=$3
    ref=$4
    
    # Find the relevant SNP set
    get-snp-fra    l$ref/$chr.vcf.gz err/l.snp
    get-snp-fra     h$to/$chr.vcf.gz err/h.snp
    get-snp-fra $fra-$to/$chr.vcf.gz err/t.snp

    # The reference SNP, or SNP exist on LD chip and used for imputation
    get-snp-with-count-num 3 err/r.snp err/{l,h,t}.snp
    
    # The imputed SNP loci
    get-snp-with-count-num 1 err/i.snp err/{t,r}.snp

    # Imputed genotypes of the 345 ID
    zcat $fra-$to/$chr.vcf.gz |
	$bin/subvcf err/{345,i.snp} >err/y

    # True genotypes
    zcat 828/$chr.vcf.gz |
	$bin/subvcf err/{345,i.snp} >err/x

    # output the error rates
    paste err/{x,y} | gawk -v chr=$chr '{print $1, chr, $2, $4}' |
	$bin/impErr >>err/$fra-$to.err
}


sum-errors(){
    rm -f err/*.err
    gawk '{print $2}' mapid/345.id >err/345

    for chr in {1..26}; do
	imputation-rates 8k         18k $chr  8k
	imputation-rates 8k         50k $chr  8k
	imputation-rates 8k          hd $chr  8k
	imputation-rates 8k-18k     50k $chr  8k
	imputation-rates 8k-18k-50k  hd $chr  8k
	imputation-rates 18k        50k $chr 18k
	imputation-rates 18k         hd $chr 18k
	imputation-rates 18k-50k     hd $chr 18k
	imputation-rates 50k         hd $chr 50k
    done
}


step-debug(){
    prepare-a-working-directory

    sum-errors
}


step-impute(){
    prepare-a-working-directory
    
    make-id-maps
    
    collect-828-hd-genotypes

    collect-step-genotypes

    step-merge-n-impute

    imputation-rates
}
