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
    rst=$work/rates.txt
    touch $rst
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
    nref=$1
    nmsk=$2
    let nid=nref+nmsk           # include reference and ID to be masked
    
    cat $work/md.id |
	    shuf |
	    head -n $nid |
	    sort -n >id.lst	# All ID in the reference

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
        $bin/cor-err >>$rst
}

test-lmr(){
    prepare-a-working-directory

    make-reference

    for nfra in 50 100 150; do
        for nto in `seq 50 100 2001`; do
            echo $nfra $nto >>$rst
            sample-g-id-n-impute $nfra $nto
        done
    done
}


lm-rate(){
    prepare-a-working-directory

    make-reference

    for nfra in `seq 50 100 2001`; do
        for nto in 50 100 150; do
            echo $nfra $nto >>$rst
            sample-g-id-n-impute $nfra $nto
        done
    done

    $bin/l2mcol < $rst >6c
    ## some Julia codes below for plotting a figure
    #using DelimitedFiles, Plots
    #rst = readdlm("6c")
    #x = 200:100:2001
    #p1=plot(x, dat[:,[1,3,5]],
    #        xlabel="Total number of ID (imputed+reference)",
    #        ylabel="Imputation error rate",
    #        label=["imp=50" "imp=100" "imp=150"],
    #        lw=2, minorticks=200:100:2001,
    #        dpi=300)
    #savefig("impute.png")
}
