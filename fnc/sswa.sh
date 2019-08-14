# Single step with absorption
prepare-dir(){
    echo Prepare a working directory
    cd ssa/
    make
    make mv

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

g-mat(){
    dpth=$base/work/ld2md	# dependent path
    idlst=lm.id
    gmat=ld-md.G
    
    if [ ! -d $dpth ]; then
	source $func/ld2md.sh
	ld2md
    fi
    
    cd $work
    #translate ID
    cat $dpth/$idlst |
	$bin/transid ped.dict >ori.id

    sort ori.id > g.id

    $bin/subMat $dpth/$gmat ori.id g.id g.G
}
