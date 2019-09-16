# check imputation rate from 8k to 17k
# Several thousand of ID were genotyped with 17k chips
# 8k is majorly a subset of 17k,
# it is handy to mask a few to check imputation.
# -------------------
# My previous imputation seems like too good to be true
# So I am using less reference to impute
# Hoping to find a concordance increment curve when the reference size increases

prepare-a-working-directory(){
    if [ ! -d $base/work/a17k.g ]; then
    	source $base/fnc/g17ka.sh
	    calc-ga17k
    fi

    work=$base/work/l2m.rate
    if [ -d $work ]; then rm -rf $work; fi # for debug purpose
    
    mkdir -p $work/{dat,tst}
    dat=$work/dat
    tst=$work/tst
    cd $work
}

make-reference(){
    cd $dat
    for chr in {1..26}; do
    	ln -sf $base/work/a17k.g/pre/$chr.vcf.gz  md.$chr.vcf.gz
	    ln -sf $base/work/a17k.g/imp/$chr.vcf.gz ref.$chr.vcf.gz
    done

    zcat md.{1..26}.vcf.gz |
    	grep -v \# |
        gawk '{print $3}' >$work/md.snp

    cat $maps/7327.map | 
	    gawk '{print $2}' >$work/ld.snp
    
    cat $work/ld.snp |
	    $bin/impsnp $work/md.snp >$work/imputed.snp

    zcat ref.1.vcf.gz |
    	head |
    	tail -1 |
	    tr '\t' '\n' |
	    tail -n+10 > $work/md.id
}

sample-g-id-n-impute(){
    cd $tst
    nid=$1			# include reference and ID to be masked
    nmsk=50			# 50 are enough for imputation test
    
    cat $work/md.id |
	    shuf |
	    head -n $nid |
	    sort -n >id.lst	# All ID in the reference

    let nref=nid-nmsk
    cat <(yes 1 | head -$nref) <(yes 0 | head -$nmsk) |
        shuf >mask

    for chr in {1..26}; do
	    zcat $dat/ref.$chr.vcf.gz |
	        $bin/subid id.lst |
	        gzip -c > ref.$chr.vcf.gz
	    zcat $dat/md.$chr.vcf.gz  |
	        $bin/subid id.lst |
	        $bin/maskmd mask $work/ld.snp |
	        gzip -c >msk.$chr.vcf.gz
	    java -jar $bin/beagle.jar \
	         gt=msk.$chr.vcf.gz \
	         ne=$ne \
	         out=imp.$chr
    done
    
    paste id.lst mask |
        gawk '{if($2==0) print $1}' > mskt.id
    zcat imp.{1..26}.vcf.gz |
    	$bin/subvcf mskt.id $work/imputed.snp >imp.gt
    zcat ref.{1..26}.vcf.gz |
    	$bin/subvcf mskt.id $work/imputed.snp >ref.gt
    paste {ref,imp}.gt |
        $bin/cor-err >>rates.txt
}

test-lmr(){
    prepare-a-working-directory

    make-reference

    sample-g-id-n-impute 4000
#    for smp in `seq 100 100 4750`; do
#        echo $smp >>rates.txt
#        sample-g-id-n-impute $smp
#    done
}


lm-rate(){
    prepare-a-working-directory

    make-reference

    determine-sizes

    for i in `seq $rpt`; do
	    sample-n-mask-n-impute
    done
}
