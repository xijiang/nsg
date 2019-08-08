prepare-files(){
    # Description:
    # Impute LD(7327) to MD 17k (16227), all 7325 shared, 7029 autosome SNP shared
    # LD has 7031 autosome loci, including some repeated.
    # then calculate a G matrix of these individual

    # a work space
    work=$base/work/ld2md
    mkdir -p $work
    cd $work

    # link the available genotypes here
    LD=`ls $genotypes/7327`
    ln -sf $genotypes/7327/* .
    MD=`ls $genotypes/a17k`
    ln -sf $genotypes/a17k/* .
}


collect-ld-genotypes(){
    # find the LD genotypes of the 345 ID
    tail -n+2 $ids/id.lst |
        gawk '{if(length($3)>5 && $9==10) print $3, $2}' > ld.id

    cat $maps/7327.map | 
	gawk '{print $2, $1, $4}' > ld.map

    $bin/mrg2bgl ld.id ld.map $LD
    
    for chr in {26..1}; do
	java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
	    gzip -c >ld.$chr.vcf.gz
    done
}


collect-md-genotypes(){
    # find the HD genotypes of those who only genotyped with HD chips
    tail -n+2 $ids/id.lst |
        gawk '{if(length($6)>5 && $9==10) print $6, $2}' >md.id

    tail -n+2 $maps/a17k.map |
    	gawk '{print $2, $1, $4}' > md.map

    $bin/mrg2bgl md.id md.map $MD

    for chr in {26..1}; do
	java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
            gzip -c >md.$chr.vcf.gz
    done
}


merge-md-ld-then-impute(){
    # merge the 483 (HD) and 345 (LD) and impute the 345 to HD level
    for chr in {26..1}; do
	# left join ld.vcf to hd.vcf
	# hd.{1..26}.vcf.gz ld.{1..26}.vcf.gz ---> tmp.{1..26}.vcf.gz
	$bin/ljvcf <(zcat md.$chr.vcf.gz) <(zcat ld.$chr.vcf.gz) |
	    gzip -c >tmp.$chr.vcf.gz
	
        java -jar $bin/beagle.jar \
             gt=tmp.$chr.vcf.gz \
             ne=$ne \
             out=imp.$chr
    done

    calc-g imp ld-md.G
    zcat imp.1.vcf.gz |
	head |
	tail -1 |
	tr '\t' '\n' |
	tail -n+10 >lm.id
    cat ld-md.G |
	$gmt/g2-3c lm.id >lim.3c

}


ld2md(){
    prepare-files

    collect-ld-genotypes

    collect-md-genotypes

    merge-md-ld-then-impute
}
