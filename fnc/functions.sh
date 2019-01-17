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

    echo -n https://faculty.washington.edu/browning/beagle/
    curl -sl https://faculty.washington.edu/browning/beagle/ |
        grep beagle.*jar |
        gawk -F\" '{print $6}' |
        gawk -F\. '{if(NF==4) print $0}' |
        $bin/latest-beagle
}


get-beagle-related(){
    beagle=`the-latest-beagle`
    cd $bin
    curl $beagle -o beagle.jar
    echo  Beagle used: $beagle

    wget https://faculty.washington.edu/browning/beagle_utilities/beagle2vcf.jar
    cd $base
}


calc-g(){
    for chr in {1..26}; do
	zcat $1.$chr.vcf.gz
    done |
	$bin/vcf2g |
	$bin/bpxvr1g >$2
}
