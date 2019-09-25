CXXFLAGS = -O2 -Wall -std=c++17
THREAD = ${CXXFLAGS} -pthread

target=latest-beagle mrg2bgl subMat ljvcf pasteG range subvcf pksnp het-rt \
	subid cls-ave subMap afrq maskmd vcf2g vr1g g2-3c impsnp impErr cor-err\
	vcfstat impsub l2mcol mskloci extrvcf

all:    ${target}

mv:
	mkdir -p ../bin
	mv ${target} ../bin
