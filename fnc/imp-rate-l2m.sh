# check imputation rate from 8k to 17k
# Several thousand of ID were genotyped with 17k chips
# 8k is majorly a subset of 17k,
# it is handy to mask a few to check imputation.
prepare-a-working-directory(){
    if [ ! -d $base/work/a17k.g ]; then
	source $base/fnc/g17ka.sh
	calc-ga17k
    fi

    work=$base/work/l2m.rate
    mkdir -p $work
    cd work
    ln -sf $base/work/a17k.g/md.{1..26}.vcf.gz .
    # The SNP on the 7k chip
    cat $maps/7327.map |
	gawk '{print $2}' >ld.snp
}


determine-sizes(){
    nid=`zcat md.1.vcf.gz | head | tail -1 | tr '\t' '\n' | wc | gawk '{print $1}'`
    let nid=nid-9
    msk=500
    let ref=nid-msk

    rpt=20
}    
    

sample-n-mask-n-impute(){
    yes 0 | head -$msk > tmp
    yes 1 | head -$ref >>tmp
    cat tmp |
	shuf > mask.idx

    for chr in {26..1}; do
	cat md.$chr.vcf.gz |
	    $/bin/maskmd mask.idx ld.snp |
	    gzip >msk.$chr.vcf.gz
	java -jar $bin/beagle.jar \
	     gt=msk.$chr.vcf.gz \
	     ne=$ne \
	     out=imp.$chr
	$bin/cmpimp <(zcat ref.$chr.vcf.gz) <(zcat imp.$chr.vcf.gz) mask.idx ld.snp
    done
}


test-lmr(){
    prepare-a-working-directory

    determine-sizes

    sample-n-mask-n-impute
}


lm-rate(){
    prepare-a-working-directory

    determine-sizes

    for i in `seq $rpt`; do
	sample-n-mask-n-impute
    done
}
