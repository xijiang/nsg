CXXFLAGS = -O2 -Wall -std=c++17
THREAD = ${CXXFLAGS} -pthread

target=latest-beagle mrg2bgl vcf2g viewg subMat ljvcf pasteG g2dmu ccgmat range

all:    ${target}

ccgmat:	ccgmat.cpp
	g++ ${THREAD} -o ccgmat ccgmat.cpp

mv:
	mkdir -p ../bin
	mv ${target} ../bin
