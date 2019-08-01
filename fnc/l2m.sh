l2m(){
    # Description:
    # Impute LD(7327) to MD 17k (16227), all 7325 shared, 7029 autosome SNP shared 
    # then calculate a G matrix of these individual

    # a work space
    work=$base/work/ld2md
    mkdir -p $work
    cd $work

    # link the available genotypes here
    ld=`ls $genotypes/7327`
    ln -s $genotypes/7327/* .
    md=`ls $genotypes/a17k`
    ln -s $genotypes/a17k/* .

    # see if imputed the minors before
    if [ ! -d $base/work/7327.g ]; then
	source $base/fnc/g3727.sh
	calc-g7327
    fi
    if [ ! -d $base/work/a17k.g ]; then
	source $base/fnc/g17ka.sh
	calc-ga17k
    fi
    for i in {1..26}; do
	ln -s $base/work/7327.g/imp.$i.vcf.gz ld.$i.vcf.gz
	ln -s $base/work/a17k.g/imp.$i.vcf.gz md.$i.vcf.gz
    done

    # prepare the files for imputation
}
##############################################################################
# This subroutine is to find the loci that are most poorly imputed.
# I splitted the job into the following steps.
##############################################################################

prepare-a-working-directory(){
    ############################################################
    # Create a separate work space
    work=$base/work/t345
    mkdir -p $work
    cd $work

    # soft link the genotypes here
    for i in $G7327 $G600K; do
	ln -sf $genotypes/$i .
    done
}


collect-345-ld-genotypes(){
    # find the LD genotypes of the 345 ID
    cat $genotypes/$idinfo |
        gawk '{if(length($3)>5 && length($4)>5) print $3, $2}' > idinfo

    cat $maps/$map7327 | 
	gawk '{print $2, $1, $4}' > mapinfo

    $bin/mrg2bgl idinfo mapinfo $G7327
    
    for chr in {26..1}; do
	java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
	    gzip -c >ld.$chr.vcf.gz
    done
}


collect-483-hd-genotypes(){
    # find the HD genotypes of those who only genotyped with HD chips
    cat $genotypes/$idinfo |
        gawk '{if(length($4)>5 && length($3)<5) print $4, $2}' >idinfo

    tail -n+2 $maps/$snpchimpv40 |
    	gawk '{print $13, $11, $12}' > mapinfo

    echo Left merging genotypes
    $bin/mrg2bgl idinfo mapinfo $G600K

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


test-345(){
    prepare-a-working-directory
    
    compare-imputed-and-hd-to-find-bad-loci
}


calc-345(){
    prepare-a-working-directory

    collect-345-ld-genotypes

    collect-483-hd-genotypes

    merge-483-345-then-impute

    collect-345-hd-genotypes-impute

    collect-n-impute-345-ld-genotypes

    compare-imputed-and-hd-to-find-bad-loci
}
