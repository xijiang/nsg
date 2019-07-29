#!/usr/bin/env bash

# This is to collect data for my NSG project
# -- HD and LD genotypes
# -- linkage maps from SNPchiMp
# -- ID information for genotyping methods
# -- ID and loci to be ignored
. fnc/pars.sh
. fnc/functions.sh

echo Check submodules
echo G-matrix related
if [ ! -d gmt ]; then
    git clone https://github.com/xijiang/gmat gmt
else
    cd gmt
    git pull
    cd ..
fi

echo Updating data
if [ ! -d data ]; then
    #git clone git.nmbu.org:data/git/nsg-data data
    echo please copy the genotypes, maps and other info to data/
fi

# This is to collect my codes for above data
echo Update binaries
echo Binaries for NSG
cd src/				# update the binaries
make
make mv
cd ..

echo Binaries from gmat project
cd gmt/src
make
make mv
cd -

echo Check if Beagle 5 is ready

if [ ! -f bin/beable2vcf.jar ]; then
    get-beagle-related
fi
