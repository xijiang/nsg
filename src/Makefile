CXXFLAGS = -O2 -Wall -std=c++17
THREAD = ${CXXFLAGS} -pthread

target=latest-beagle mrg2bgl subMat ljvcf pasteG range subvcf pksnp het-rt \
	subid cls-ave subMap

all:    ${target}

mv:
	mkdir -p ../bin
	mv ${target} ../bin
