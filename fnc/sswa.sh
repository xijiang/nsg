# Single step with absorption
prepare-dir(){
    echo Prepare a working directory
    if [ ! -f $bin/dnt ]; then
	cd ssa/
	make
	make mv
    fi
    work=$base/work/absorb
    mkdir -p $work
    cd $work
}


calc-dnt(){
    # used 17 minutes on nmbu.org, single thread
    ln -sf $phenotypes/NKSped2503.txt ped.txt
    ln -sf $phenotypes/PTD_KULL.txt trait.txt

    cat ped.txt |
	$bin/sortped >sorted.ped 2>ped.dict

    echo Prepare for Julia scripts
    cat sorted.ped | $bin/dnt
}


