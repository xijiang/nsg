##############################################################################
# This subroutine is to find the loci that are most poorly imputed.
# I splitted the job into the following steps.
##############################################################################

prepare-a-working-directory(){
    ############################################################
    # Create a separate work space
    # work=$base/work/`date +%Y-%m-%d-%H-%M-%S`
    work=$base/work/test
    mkdir -p $work
    cd $work

    # soft link the genotypes here
    for i in $G7327 $G600K; do
	ln -sf $genotypes/$i .
    done
}

gether-345-ld-genotypes(){
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


gether-483-hd-genotypes(){
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


gether-345-hd-genotypes-impute(){
    # gether the 345 HD genotypes, and impute the few missing genotypes.
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
    for chr in {1..26}; do
	$bin/imperr <(zcat 345.$chr.vcf.gz) \
		    <(zcat imp.$chr.vcr.gz) > $chr.err
    done
}



calc-345(){
    prepare-a-working-directory

    gether-345-ld-genotypes

    gether-483-hd-genotypes

    merge-483-345-then-impute

    gether-345-hd-genotypes-impute

    compare-imputed-and-hd-to-find-bad-loci
}


t345(){
    cd $base/work/test
    
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
