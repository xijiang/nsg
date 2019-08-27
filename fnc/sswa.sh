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
    cd $phenotypes
    if [ ! -f $work/litter.pht ]; then
	make
	cat Litter-AnE.txt |
	    ./chk-litter |
	    ./id+a+e |
	    $bin/match ped.dict |
	    sort -nk1 >litter.pht
	
	mv litter.pht $work
    fi
    cd $work
}

G-n-genotypes(){
    # calculate a G matrix in the training set
    dpth=$base/work/ld2md	# dependent path
    if [ ! -d $dpth ]; then
	source $func/ld2md.sh
	ld2md
    fi
    work=$base/work/absorb	# write back current work directory

    # -- find the ID in the training set
    # -- note:
    # ---- training set include the animal ID and coded ID
    # ---- validation included only the animal ID
    idlst=lm.id
    cat $dpth/$idlst |
	$bin/groupid ped.dict training.id Zv.id

    sort -nk2 training.id >tmp
    gawk '{print $1}' tmp >Zt.id
    gawk '{print $2}' tmp >idx.id
    
    # -- genotypes zt and zv
    zcat $dpth/imp/{1..26}.vcf.gz |
	groupgt Zt.id Zv.id Zt.gt Zv.gt

    # -- genotypes of validation set
    zcat $dpth/imp/{1..26}.vcf.gz |
	
    # prepare genotypes in the validation set
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
