#!/usr/bin/env bash
if [ $# != 1 ]; then
    echo Usage: ./run-pipe.sh option
    echo options:
    echo -e "\t"LD:  construct a G matrix with LD data on 3721 ID
    echo -e "\t"HD:  construct a G matrix with HD data on 828 ID
    echo -e "\t"IMP: construct a G matrix with imputation on 4204 ID
    echo -e "\t"345: using 345 HD and LD infor to test error rate
else
    echo preparing functions
    . fnc/pars.sh
    . fnc/functions.sh

    # Genotype files
    . $base/data/genotypes/groups.sh

    # Map files
    . $base/data/maps/maps.sh

    case "$1" in
	LD|ld|Ld)
	    source fnc/g7327.sh
	    calc-g7327
	    ;;
	HD|hd|Hd)
	    source fnc/g600k.sh
	    calc-g600k
	    ;;
	IMP|imp|Imp)
	    source fnc/hdimp.sh
	    calc-hdimp
	    ;;
	345)
	    source fnc/imp-rate-345.sh
	    ;;
    esac
fi
