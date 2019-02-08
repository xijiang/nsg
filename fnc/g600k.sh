calc-g600k(){
    # Create a separate work space
    work=$base/work/`date +%Y-%m-%d-%H-%M-%S`
    mkdir -p $work
    cd $work

    # link the available genotype files here
    for i in $G600K; do
	ln -s $genotypes/$i .
    done
    
    # make ID info and map ready
    tail -n+2 $genotypes/$idinfo |
	gawk '{if(length($4)>5) print $4, $2}' > idinfo

    tail -n+2 $maps/$snpchimpv40 |
	gawk '{print $13, $11, $12}' > mapinfo

    $bin/mrg2bgl idinfo mapinfo $G600K # linked here already

    for chr in {26..1}; do
	java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
            gzip -c >tmp.$chr.vcf.gz

        java -jar $bin/beagle.jar \
             gt=tmp.$chr.vcf.gz \
             ne=$ne \
             out=imp.$chr
    done

    calc-g imp hd-only.G
    cp gmat.id hd-only.G.id
}
