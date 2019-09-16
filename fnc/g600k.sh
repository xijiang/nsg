calc-g600k(){
    # Create a separate work space
    work=$base/work/600k.g
    mkdir -p $work
    cd $work

    # link the available genotype files here
    gfiles=`ls $genotypes/600k/`
    ln -s $genotypes/600k/* .
    
    # make ID info and map ready
    tail -n+2 $ids/id.lst |
	    gawk '{if(length($4)>2 && $7<2000 && $10==1) print $4, $2}' > idinfo
    tail -n+2 $ids/id.lst |
	    gawk '{if(length($4)>2 && $7>1999 && $9==10) print $4, $2}' >>idinfo
    
    tail -n+2 $maps/sheep-snpchimp-v.4 |
	    gawk '{print $13, $11, $12}' > mapinfo

    $bin/mrg2bgl idinfo mapinfo $gfiles # linked here already

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
    cat hd-only.G |
	    $bin/g2-3c hd-only.G.id >600k.G
}
