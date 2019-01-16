calc-g600k(){
    cd $work

    # link the available genotype files here
    for i in $G600K; do
	ln -s $genotypes/$i .
    done
    
    # make ID info and map ready
    cat $genotypes/$idinfo |
	gawk '{if(length($4)>5) print $4, $1}' >idinfo

    cat $maps/$map600k | 
	gawk '{print $2, $1, $4}' > mapinfo

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
