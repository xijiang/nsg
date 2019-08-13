#!/usr/bin/env bash
source fnc/pars.sh 
source fnc/sswa.sh

prepare-dir

litter-pht			# litter size phenotypes

# time calc-dnt			# for A inverse calculation

$ssa/absorb.jl
