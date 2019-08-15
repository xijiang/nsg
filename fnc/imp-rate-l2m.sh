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
    cd $work
    for chr in {1..26}; do
	ln -sf $base/work/a17k.g/imp.$chr.vcf.gz md.$chr.vcf.gz
    done
}


make-reference(){
    for chr in {1..26}; do
        java -jar $bin/beagle.jar \
             gt=md.$chr.vcf.gz \
             ne=$ne \
             out=ref.$chr
    done
    # The SNP on the 7k chip
    cat $maps/7327.map | 
	gawk '{print $2, $1, $4}' > ld.snp

    zcat md.{1..26}.vcf.gz |
	grep -v \# |
	gawk '{print $3}' >md.snp

    cat ld.map |
	gawk '{print $1}' |
	$bin/impsnp super.snp >imputed.snp

    zcat md.1.vcf.gz |
	head |
	tail -1 |
	tr '\t' '\n' |
	tail -n+10 >md.id
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

    make-reference

}


lm-rate(){
    prepare-a-working-directory

    make-reference

    determine-sizes

    for i in `seq $rpt`; do
	sample-n-mask-n-impute
    done
}
