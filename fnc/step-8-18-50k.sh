##############################################################################
# This script is to test the imputation rates for various panels
# Data:
#  1. Full panel: 606k, 828ID
#  2. 17k \in 50k \in 606k
#  3. 8k are majorly \in 17k
# Method:
#  1. Extract 17k, & 50k results of the 345 ID from genotypes of  828ID
#  2. impute and compare
##############################################################################

prepare-a-working-directory(){
    ############################################################
    # Create a working directory
    work=$base/work/step--8-18k-50k-hd
    mkdir -p $work
    cd $work

    # soft link the genotypes here
    for i in $G600K; do
	ln -sf $genotypes/$i .
    done
}


collect-828-hd-genotypes(){
    grep -v ^# $genotypes/genotyped.id |
	gawk '{if(length($5)>5) print $5, $2}' >idinfo

    tail -n+2 $maps/$snpchimpv40 |
    	gawk '{print $13, $11, $12}' > mapinfo

    echo Create beagle files
    $bin/mrg2bgl idinfo mapinfo $G600k

    for chr in {26..1}; do
	java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
	    gzip -c >tmp.$chr.vcf.gz
	
	java -jar $bin/beagle.jar \
	     gt=tmp.$chr.vcf.gz \
	     ne=$ne \
	     out=828.$chr
    done
}


collect-483-hd-genotypes(){
    # find the HD genotypes of those who only genotyped with HD chips
    grep -v ^# $genotypes/genotyped.id |
	gawk '{if(length($5)>5 && length($4)<5) print $5, $2}' >idinfo

    tail -n+2 $maps/$snpchimpv40 |
    	gawk '{print $13, $11, $12}' > mapinfo

    echo Create beagle files
    $bin/mrg2bgl idinfo mapinfo $G600K

    for chr in {26..1}; do
	java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
            gzip -c >tmp.$chr.vcf.gz
    done
}


collect-345-18k-genotypes(){
    # find the 15k genotypes of the 345 ID
    grep -v ^# $genotypes/genotyped.id |
	gawk '{if(length($4)>5 && length($5)>5) print $5, $2}' > idinfo

    tail -n+2 $maps/$snpchimpv40 |
	$bin/subMap $maps/18k.snp >mapinfo

    $bin/mrg2bgl idinfo mapinfo $G7327
    
    for chr in {26..1}; do
	java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
	    gzip -c >18k.$chr.vcf.gz
    done
}


merge-483-345-then-impute(){
    # merge the 483 (HD) and 345 (LD) and impute the 345 to HD level
    for chr in {26..1}; do
	# left join ld.vcf to hd.vcf
	# hd.{1..26}.vcf.gz ld.{1..26}.vcf.gz ---> tmp.{1..26}.vcf.gz
	$bin/ljvcf <(zcat hd.$chr.vcf.gz) <(zcat ld.$chr.vcf.gz) |
	    gzip -c >tmp.$chr.vcf.gz
	
        java -jar $bin/beagle.jar \
             gt=tmp.$chr.vcf.gz \
             ne=$ne \
             out=imp.$chr
    done
}


collect-345-hd-genotypes-impute(){
    # collect the 345 HD genotypes, and impute the few missing genotypes.
    cat $genotypes/$idinfo |
        gawk '{if(length($3)>5 && length($4)>5) print $4, $2}' > idinfo

    tail -n+2 $maps/$snpchimpv40 |
    	gawk '{print $13, $11, $12}' > mapinfo

    $bin/mrg2bgl idinfo mapinfo $G600K # merge and split to beagle

    for chr in {26..1}; do
	java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
            gzip -c >tmp.$chr.vcf.gz

        java -jar $bin/beagle.jar \
             gt=tmp.$chr.vcf.gz \
             ne=$ne \
             out=345.$chr
    done
}


compare-imputed-and-hd-to-find-bad-loci(){
    # the 345 ID who were genotyped with both LD and HD chips
    cat $genotypes/$idinfo |
        gawk '{if(length($3)>5 && length($4)>5) print $2}' > 345.id

    # the imputed loci and their HD and imputed genotypes
    rm -f *.snp			# if exist
    for chr in {1..26}; do
	zcat 345.$chr.vcf.gz |
	    tail -n+11 |
	    gawk '{print $3}' >>345-hd.snp
	zcat ild.$chr.vcf.gz |
	    tail -n+11 |
	    gawk '{print $3}' >>345-ld.snp
	zcat imp.$chr.vcf.gz |
	    tail -n+11 |
	    gawk '{print $3}' >>imp-hd.snp
	zcat 345.$chr.vcf.gz |
	    tail -n+11 |
	    gawk -v chr=$chr '{print $3, chr}' >>snp-chr.snp
    done

    cat 345-hd.snp 345-ld.snp imp-hd.snp |
	sort |
	uniq -c |
	gawk '{if($1==3) print $2}' >shared.snp

    cat 345-hd.snp shared.snp |
	sort |
	uniq -c |
	gawk '{if($1==1) print $2}' >ref.snp

    cat imp-hd.snp shared.snp |
	sort |
	uniq -c |
	gawk '{if($1==1) print $2}' >imp.snp

    cat ref.snp imp.snp |
	sort |
	uniq -c |
	gawk '{if($1==2) print $2}' >check.snp

    cat snp-chr.snp |
	$bin/pksnp check.snp >snp.chr

    # then find the HD control and imputed genotypes
    zcat 345.{1..26}.vcf.gz |
	$bin/subvcf 345.id check.snp >345.gt

    zcat imp.{1..26}.vcf.gz |
	$bin/subvcf 345.id check.snp >imp.gt

    # calculate: 
    # SNP chr allele-frq gt-error allele-error
    paste snp.chr 345.gt imp.gt |
	gawk '{print $1, $2, $4, $6}' |
	$bin/impErr >err.txt
}


collect-n-impute-345-ld-genotypes(){
    for chr in {26..1}; do
	java -jar $bin/beagle.jar \
	     gt=ld.$chr.vcf.gz \
	     ne=$ne \
	     out=ild.$chr
    done
    
    calc-g 345 th345.G
    calc-g ild tl345.G
}


step-debug(){
    prepare-a-working-directory
    
    collect-828-hd-genotypes

#    collect-483-hd-genotypes
}


calc-345(){
    prepare-a-working-directory

    collect-483-hd-genotypes

    collect-345-ld-genotypes

    collect-483-hd-genotypes

    merge-483-345-then-impute

    collect-345-hd-genotypes-impute

    collect-n-impute-345-ld-genotypes

    compare-imputed-and-hd-to-find-bad-loci
}
