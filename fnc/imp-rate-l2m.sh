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

    for chr in {1..26}; do
	ln -sf $base/work/a17k.g/tmp.$chr.vcf.gz  md.$chr.vcf.gz
	ln -sf $base/work/a17k.g/imp.$chr.vcf.gz ref.$chr.vcf.gz
    done
}    


sample-n-mask-n-impute(){
    # Create mask list
    nref=`zcat md.1.vcf.gz | head | tail -1 | tr '\t' '\n' | wc | gawk '{print $1}'`
    nmsk=500
    let nref=nref-nmsk-9
    yes 0 | head -$nmsk >tmp
    yes 1 | head -$nref>>tmp
    cat tmp | shuf >mask.idx
    rm tmp

    # The SNP on the 7k chip
    cat $maps/7327.map |
	gawk '{print $2}' >ld.snp

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




lm-rate(){
    prepare-a-working-directory
    
    sample-n-mask-n-impute

}
