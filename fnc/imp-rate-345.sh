##############################################################################
# This subroutine is to find the loci that are most poorly imputed.
# I splitted the job into the following steps.
##############################################################################

prepare-a-working-directory(){
    ############################################################
    # Pre-requests
    HD=`ls $genotypes/600k`
    LD=`ls $genotypes/7327`

    # Create a work space
    work=$base/work/345.test
    mkdir -p $work
    cd $work

    ln -sf $genotypes/600k/* .
    ln -sf $genotypes/7327/* .
}


collect-345-ld-genotypes(){
    # find the LD genotypes of the 345 ID
    tail -n+2 $ids/id.lst |
        gawk '{if(length($3)>5 && length($4)>5) print $3, $2}' > ld.id

    cat $maps/7327.map | 
	    gawk '{print $2, $1, $4}' > ld.map

    $bin/mrg2bgl ld.id ld.map $LD
    
    for chr in {26..1}; do
	    java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
	        gzip -c >ld.$chr.vcf.gz
    done
}


collect-483-hd-genotypes(){
    # find the HD genotypes of those who only genotyped with HD chips
    tail -n+2 $ids/id.lst |
        gawk '{if(length($4)>5 && length($3)<5) print $4, $2}' >hd.id

    tail -n+2 $maps/sheep-snpchimp-v.4 |
    	gawk '{print $13, $11, $12}' > hd.map

    $bin/mrg2bgl hd.id hd.map $HD

    for chr in {26..1}; do
	    java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
            gzip -c >hd.$chr.vcf.gz
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
    tail -n+2 $ids/id.lst |
        gawk '{if(length($3)>5 && length($4)>5) print $4, $2}' > hd345.id

    tail -n+2 $maps/sheep-snpchimp-v.4 |
    	gawk '{print $13, $11, $12}' > hd345.map

    $bin/mrg2bgl hd345.id hd345.map $HD # merge and split to beagle

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

    cat ld.id |
	    gawk '{print $2}' >345.id
    for i in 345 ild imp; do	# HD, LD and imputed
	    calc-g $i $i.G
	    zcat $i.1.vcf.gz |
	        head |
	        tail -1 |
	        tr '\t' '\n' |
	        tail -n+10 >tmp.id
	    $bin/subMat $i.G tmp.id 345.id tmp.G
	    cat tmp.G |
	        $bin/g2-3c 345.id >$i.3c
	    cat $i.3c |
	        gawk '{if($1==$2) print $3}' >$i.diag
	    cat $i.3c |
	        gawk '{if($1!=$2) print $3}' >$i.offd
    done

    $base/fnc/qqplotG.jl
    pdftops -eps qqp.pdf
}


imputation-rates(){
    # give the percentage of wrongly imputed genotypes of who were imputed
    # also calculate the correlation of the imputed and original genotypes.
    # Files:
    #   - imp
    #   - 345
    zcat imp.{1..26}.vcf.gz |
	    grep -v \# |
	    gawk '{print $3}' >1.snp
    zcat 345.{1..26}.vcf.gz |
	    grep -v \# |
	    gawk '{print $3}' >2.snp
    cat 1.snp 2.snp |
	    sort |
	    uniq -c |
	    gawk '{if($1==2) print $2}' >super.snp
    
    cat ld.map |
	    gawk '{print $1}' |
	    $bin/impsnp super.snp >imputed.snp

    zcat imp.{1..26}.vcf.gz |
	    $bin/subvcf 345.id imputed.snp >imp.gt
    zcat 345.{1..26}.vcf.gz |
	    $bin/subvcf 345.id imputed.snp >chp.gt

    paste chp.gt imp.gt |
	    $bin/cor-err >rate.txt
}


test-345(){
    prepare-a-working-directory
    imputation-rates
}


calc-345(){
    prepare-a-working-directory

    collect-345-ld-genotypes

    collect-483-hd-genotypes

    merge-483-345-then-impute

    collect-345-hd-genotypes-impute

    collect-n-impute-345-ld-genotypes

    imputation-rates
}
