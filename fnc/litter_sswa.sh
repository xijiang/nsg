# Single step with absorption
prepare-dir(){
    echo Prepare a working directory

    work=$base/work/litter
    mkdir -p $work
    cd $work
}

calc-dnt(){
    cd $work
    # used 3 minutes on nmbu.org, single thread
    cat $phenotypes/NKSped2503.txt |
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
	make clean
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
    work=$base/work/litter	# write back current work directory
    cd $work

    echo group genotypes into training and validation sets
    zcat $dpth/imp/{1..26}.vcf.gz |
	$bin/groupgt ped.dict	# --> t.gt, for training;  v.gt, validation

    gawk '{sub($1 FS, "")} {print $0}' t.gt   >training.zmt
    gawk '{print $1}'                  t.gt   >g.id
    gawk '{sub($1 FS, "")} {print $0}' v.gt >validation.zmt

    # construct X1, ix 0, 1, 2 here
    echo group the ID into 0, 1, 2 and 3.id, and 1, 2.y
    $bin/id0123 `wc ped.dict | gawk '{print $1}'` <(gawk '{print $1, $2+$3}' litter.pht) g.id
}

calc-gebv(){
    echo calculate GEBV
}

single-step-with-absorption(){
    prepare-dir

    time calc-dnt		# for A inverse calculation

    litter-pht			# litter size phenotypes

    groups-n-genotypes

    calc-gebv
}

test-ss(){
    echo use option ssa
}
