#!/usr/bin/env bash

# Calculate Ne with the log(het rate) with year
# -Delta(F) = b

calc-ne(){
    if [ ! -d $base/work/7327.g ]; then
	source fnc/g7327.sh
	calc-g7327
    fi
    
    work=$base/work/ne-from-ld
    mkdir -p $work
    cd $work

    ln -s $base/work/7327.g/imp.{1..26}.vcf.gz .

    # animal ID and year
    cat $ids/id.lst |
	gawk '{if(length($3)>2 && $9==10) print $2, $7}' |
	sort -nk1 >id-yr
    
    # calculate het% on animal ID => animal ID and log(het)
    zcat imp.{1..26}.vcf.gz |
	$bin/het-rt |
	sort -nk1 >id-var

    # year and ave(log(het))
    paste id-yr id-var |
	gawk '{print $2, $4}' |
	sort -nk1 |
	$bin/cls-ave > deltaf.yr

    # 2.36 yr/generation, Ne = 116
    cp $base/fnc/ne.jl .
    ./ne.jl
}
