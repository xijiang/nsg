#!/usr/bin/env bash
if [ $# -ne 1 ]
then
    echo usage: ./run.sh option
    echo The current available options:
    echo g7327: construct a G matrix for ID genotyped with chip7327 only
fi

source pars.sh
source functions.sh

case "$1" in
    'g7327')
	source fnc/g7237.sh
	calc_g;;
esac
