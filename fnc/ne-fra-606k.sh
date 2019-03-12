#!/usr/bin/env bash

# Calculate Ne with the log(het rate) with year
# -Delta(F) = b

calc-ne(){
    work=$base/work/600k-828
    cd $work

    # animal ID and year
    cat $genotypes/$idinfo |
	gawk '{if(length($4)>5) print $2, $5}' |
	sort -k1 >id-yr	# sort on animal ID
    
    # calculate het% on animal ID => animal ID and log(het)
    zcat imp.{1..26}.vcf.gz |
	$bin/het-rt |
	sort -k1 >id-var

    # year and ave(log(het))
    paste id-yr id-var |
	gawk '{print $2, $4}' |
	sort -nk1 |
	$bin/cls-ave > yr.ave
}

	

