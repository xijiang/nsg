# Single step with absorption
prepare-dir(){
    echo Prepare a working directory

    work=$base/work/absorb
    mkdir -p $work
    cd $work
}

calc-dnt(){
    cd $work
    # used 3 minutes on nmbu.org, single thread
    ln -sf $phenotypes/NKSped2503.txt ped.txt

    cat ped.txt |
	$bin/sortped >sorted.ped 2>ped.dict

    echo Prepare for Julia matrix A inverse scripts
    cat sorted.ped | $bin/dnt
}

litter-pht(){
    # Prepare some phenotypes
    if [ ! -f $work/litter.pht ]; then
	cd $phenotypes
	make
	cat Litter-AnE.txt |
	    ./chk-litter |
	    ./id+a+e |
	    $bin/match $work/ped.dict |
	    sort -nk1 >$work/litter.pht
	cd $work
    fi
}

G-n-genotypes(){
    # calculate a G matrix in the training set
    dpth=$base/work/ld2md	# dependent path
    if [ ! -d $dpth ]; then
	source $func/ld2md.sh
	ld2md
    fi
    work=$base/work/absorb	# write back current work directory
    cd $work

    echo group the ID into 0, 1, 2 and 3, and put them in order
    $/bin/id0123 ped.dict <(gawk '{print $1}' litter.pht) $dpth/lm.id
    sort -n 2.id >tmp.id
    mv tmp.id 2.id
    sort -n 3.id >tmp.id
    mv tmp.id 3.id

    echo group genotypes according ID group 2 & 3
    zcat $dpth/imp/{1..26}.vcf.gz |
	$bin/groupgt 2.id 3.id 2.gt 3.gt

    gawk '{sub($1 FS, "")} {print $0}' Zt.gt >training.zmat
    gawk '{sub($1 FS, "")} {print $0}' Zv.gt >validation.zmat

    #$ssa/absorb.jl
}

single-step-with-absorption(){
    prepare-dir

    time calc-dnt			# for A inverse calculation

    litter-pht			# litter size phenotypes

    $ssa/absorb.jl
}

test-ss(){
    cd ssa
    make
    make mv

    prepare-dir

    G-n-genotypes
}
