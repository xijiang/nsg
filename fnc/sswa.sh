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
    cat sorted.ped |
	$bin/dnt
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

groups-n-genotypes(){
    # calculate a G matrix in the training set
    dpth=$base/work/ld2md	# dependent path
    if [ ! -d $dpth ]; then
	source $func/ld2md.sh
	ld2md
    fi
    work=$base/work/absorb	# write back current work directory
    cd $work

    echo group genotypes into training and validation sets
    zcat $dpth/imp/{1..26}.vcf.gz |
	$bin/groupgt ped.dict	# --> 2.gt, for training;  3.gt, validation

    gawk '{sub($1 FS, "")} {print $0}' 2.gt   >training.zmt
    gawk '{print $1}'                  2.gt   >2.id
    gawk '{sub($1 FS, "")} {print $0}' 3.gt >validation.zmt

    # construct X1, ix 0, 1, 2 here
    echo group the ID into 0, 1, 2 and 3, and put them in order
    $bin/id0123 ped.dict <(gawk '{print $1}' litter.pht) $dpth/lm.id
    sort -n 2.id >tmp.id
    mv tmp.id 2.id
    sort -n 3.id >tmp.id
    mv tmp.id 3.id

}

calc-gebv(){
    echo calculate GEBV
}

single-step-with-absorption(){
    prepare-dir

    time calc-dnt		# for A inverse calculation

    litter-pht			# litter size phenotypes

    groups-n-genotypes

    #$ssa/absorb.jl		# output b-hat
}

test-ss(){
    echo use option ssa
}
