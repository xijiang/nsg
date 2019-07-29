#!/usr/bin/env bash

# Calculate Ne with the log(het rate) with year
# -Delta(F) = b

calc-ne(){
    if [ ! -d $base/work/600k.g ]; then
	source fnc/g600k.sh
	calc-g600k
    fi
    
    work=$base/work/ne-from-hd
    mkdir -p $work
    cd $work

    ln -s $base/work/600k.g/imp.{1..26}.vcf.gz .

    # animal ID and year
    cat $genotypes/ids/id.lst |
	gawk '{if(length($4)>2 && $7<2000 && $10==1) print $2, $7}' > id.tmp
    cat $genotypes/ids/id.lst |
	gawk '{if(length($4)>2 && $7>1999 && $9==10) print $2, $7}' >>id.tmp

    cat id.tmp |
	sort -nk1 >id-yr	# sort on animal ID
    
    # calculate het% on animal ID => animal ID and log(het)
    zcat imp.{1..26}.vcf.gz |
	$bin/het-rt |
	sort -nk1 >id-var

    # year and ave(log(het))
    paste id-yr id-var |
	gawk '{print $2, $4}' |
	sort -nk1 |
	$bin/cls-ave > yr.ave
}
