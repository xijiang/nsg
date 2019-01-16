#!/usr/bin/env bash

# This is to collect data for my NSG project
# -- HD and LD genotypes
# -- linkage maps from SNPchiMp
# -- ID information for genotyping methods
# -- ID and loci to be ignored
. fnc/pars.sh
. fnc/functions.sh

if [ ! -d data ]; then
    echo Copying the source data
    git clone git.nmbu.org:doc/git/nsg/data
else
    echo Updating the source data
    cd data
    git pull 			# Update available data
    cd ..
fi

# This is to collect my codes for above data
mkdir -p bin
cd src/				# update the binaries
make
make mv
cd ..

if [ ! -f bin/beable2vcf.jar ]; then
    get-beagle-related
fi
