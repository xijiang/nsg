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


# Genotype files
. $base/data/genotypes/groups.sh

# Map files
. $base/data/maps/maps.sh

case "$1" in
    'g7327')
	source fnc/g7237.sh
	calc-g7327;;
esac
