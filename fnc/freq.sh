plot-freq(){
    if [ ! -d $base/work/7327.g ]; then
	source $base/fnc/g7327.sh
	calc-7327
    fi

    if [ ! -d $base/work/a17k.g ]; then
	source fnc/g17ka.sh
	calc-ga17k		# with genotype 17k alpha
    fi

    if [ ! -d $base/work/600k.g ]; then
	source fnc/g600k.sh
	calc-g600k
    fi

    work=$base/work/freq.plot
    mkdir -p $work
    cd $work

    for i in {1..26}; do
	zcat $base/work/7327.g/imp.$i.vcf.gz |
	    $bin/afrq >>ld.frq
	zcat $base/work/a17k.g/imp.$i.vcf.gz |
	    $bin/afrq >>md.frq
	zcat $base/work/600k.g/imp.$i.vcf.gz |
	    $bin/afrq >>hd.frq
    done

    $base/fnc/frq.jl

    convert frq.ps frq.eps
}
