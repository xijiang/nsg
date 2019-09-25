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

    work=$base/work/test-l2m
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


test-beagle-opt(){
    cd $tst
    nref=$1
    nmsk=$2
    let nid=nref+nmsk

    cat $work/md.id |
	    shuf |
	    head -n $nid >id.ist
    head -n $nref >ref.id
    tail -n $nmsk >msk.id

    for chr in {1..26}; do
        zcat $dat/ref.$chr.vcf.gz |
            $bin/subid ref.id |
            gzip -c >ref.$chr.vcf.gz
        zcat $dat/ref.$chr.vcf.gz |
            $bin/subid msk.id |
            extrvcf ld.snp >cmp.gt
        zcat $dat/md.$chr.vcf.gz |
            $bin/subid msk.id |
            $bin/mskloci $work/ld.snp |
            gzip -c >msk.$chr.vcf.gz
        java -jar $bin/beagle.jar \
             ref=ref.$chr.vcf.gz \
             gt=msk.$chr.vcf.gz \
             ne=$ne \
             out=imp.$chr
        zcat imp.$chr.vcf.gz |
            extrvcf ld.snp >imp.gt
    done
    zcat $dat/ref.{1..26}.vcf.gz |
        $bin/subid msk.id |
        $bin/extrvcf ld.snp >cmp.gt
    zcat imp.{1..26}.vcf.gz |
        $bin/extrvcf ld.snp >imp.gt
    paste cmp.gt imp.gt |
        $bin/cor-err >>$rst
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

divide-n-impute(){
    cd $tst
    cat $work/md.id |
	    shuf >tmp.id
    head -n 2000 tmp.id >ref.id
    tail -n+2001 tmp.id |
	    split -a3 -dl50		# -> x0{01..95}
    for idimp in x0*; do
	    nmsk=`wc $idimp | gawk '{print $1}'`
	    cat <(yes 1 | head -2000) <(yes 0 | head -$nmsk) >mask
	    cat ref.id $idimp >id.lst
	    for chr in {1..26}; do
	        zcat $dat/ref.$chr.vcf.gz |
		        $bin/subid id.lst |
		        gzip -c >ref.$chr.vcf.gz
	        zcat $dat/md.$chr.vcf.gz |
		        $bin/subid id.lst |
		        $bin/maskmd mask $work/ld.snp |
		        gzip -c >msk.$chr.vcf.gz
	        java -jar $bin/beagle.jar \
		         gt=msk.$chr.vcf.gz \
		         ne=$ne \
		         out=imp.$chr
	    done
	    zcat imp.{1..26}.vcf.gz |
	        $bin/subvcf $idimp $work/imputed.snp >imp.$idimp
	    zcat ref.{1..26}.vcf.gz |
	        $bin/subvcf $idimp $work/imputed.snp >ref.$idimp
    done
}

test-lmr(){
    prepare-a-working-directory

    make-reference

    for nto in `seq 50 100 2001`; do
        echo 1000 $nto >>$rst
        test-beagle-opt 1000 $nt
    done
    
    # echo Use option lmr
}

lm-rate(){
    prepare-a-working-directory

    make-reference

    # Use small set of reference, impute more
    for nfra in 50 100 150; do
        for nto in `seq 50 100 2001`; do
	        echo $nfra $nto >>$rst
	        sample-g-id-n-impute $nfra $nto
        done
    done
    $bin/l2mcol < $rst >6c
    # Julia plot code
    # p1 = plot(x, rst[:, [1,3,5]],
    #           xlabel="Impuated pop size",
    #           ylabel="Imputation error rate",
    #           label=["ref=50" "ref=100" "ref=150"],
    #           lw=2,
    #           minorticks=50:100:2001,
    #           dpi=300,
    #           legend=:bottomright)

    # Use fixed set of ID to be imputed, increase reference set.
    mv $rst 1.rst
    touch $rst
    for nto in 50 100 150; do
        for nfra in `seq 50 100 2001`; do
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

    # to see the varation with same ref and imp set size.
    echo 2000 50 >$rst
    for i in {1..100}; do
        sample-g-id-n-impute 2000 50
    done
    cat rates.txt |
	    grep rate |
	    gawk '{print $4}' >1c
}
