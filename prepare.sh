#!/usr/bin/env bash

# This is to collect data for my NSG project
# -- HD and LD genotypes
# -- linkage maps from SNPchiMp
# -- ID information for genotyping methods
# -- ID and loci to be ignored
if [ ! -d data ]; then
    echo Copying the source data
    git clone git.nmbu.org:doc/git/nsg/data
else
    echo Updating the source data
    cd data
    git pull 			# Update available data
fi

# This is to collect my codes for above data
cd src/				# update the binaries
make
make mv

# Get the latest Beagle
# -- Notice the name of nightly Beagle is like beagle.ddMMMyy.xyz.jar
# -- at the following URL
# -- So, I ordered them on yymmdd, and return the absolute address
# -- of the latest Beagle.
the-latest-beagle(){
    # Notice the name of nightly Beagle is like beagle.ddMMMyy.xyz.jar
    # at the following URL
    # So, I ordered them on yymmdd, and return the absolute address
    # of the latest Beagle.

    echo -n https://faculty.washington.edu/browning/beagle
    curl -sl https://faculty.washington.edu/browning/beagle |
        grep beagle.*jar |
        gawk -F\" '{print $6}' |
        gawk -F\. '{if(NF==4) print $0}' |
        bin/latest-beagle
}

get-beagle-related(){
    beagle=`the-latest-beagle`
    curl $beagle -o beagle.jar
    echo  Beagle used: $beagle

    wget https://faculty.washington.edu/browning/beagle_utilities/beagle2vcf.jar
}

if [ ! -f bin/beable2vcf.jar ]; then
    get-beagle-related
fi
