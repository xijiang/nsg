#!/usr/bin/env bash
source fnc/pars.sh 
source fnc/sswa.sh

prepare-dir

time calc-dnt			# for A inverse calculation

litter-pht			# litter size phenotypes

$ssa/absorb.jl
