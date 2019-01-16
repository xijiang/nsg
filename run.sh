#!/usr/bin/env bash
if [ $# -ne 1 ]
then
    echo usage: ./run.sh option
    echo
    echo The current available options:
    echo
    echo \ \ g7327: G for ID genotyped with chip7327
    echo
    echo \ \ g600k: G for ID genotyped with chip600k
    echo
    echo \ \ hdimp: G for ID genotyped with chip600k and chip7327, impute the latter
    echo
fi

. fnc/pars.sh
. fnc/functions.sh

mkdir -p $work

# Genotype files
. $base/data/genotypes/groups.sh

# Map files
. $base/data/maps/maps.sh

case "$1" in
    'g7327')
	source fnc/g7327.sh
	calc-g7327;;
    'g600k')
	source fnc/g600k.sh
	calc-g600k;;
    'hdimp')
	source fnc/hdimp.sh
	calc-hdimp;;
esac
