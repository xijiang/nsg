#!/usr/bin/env bash
if [ $# -ne 1 ]
then
    echo usage: ./run.sh option
    echo
    echo The current available options:
    echo
    echo \ \ g7327: construct a G matrix for ID genotyped with chip7327 only
    echo
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
esac
