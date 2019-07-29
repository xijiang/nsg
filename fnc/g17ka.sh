calc-ga17k(){
    # Create a separate work space
    #work=$base/work/`date +%Y-%m-%d-%H-%M-%S`
    work=$base/work/a17k.g
    mkdir -p $work
    cd $work

    # link the available genotype files here
    gfiles=`ls $genotypes/a17k/`
    ln -s $genotypes/a17k/* .
    
    # make ID info and map ready
    tail -n+2 $ids/id.lst |
	gawk '{if(length($6)>2 && $9==10 && $7>1999) print $6, $2}' >idinfo
    
    cat $maps/a17k.map | 
	gawk '{print $2, $1, $4}' > mapinfo

    $bin/mrg2bgl idinfo mapinfo $gfiles

    for chr in {26..1}; do
	java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
            gzip -c >tmp.$chr.vcf.gz

        java -jar $bin/beagle.jar \
             gt=tmp.$chr.vcf.gz \
             ne=$ne \
             out=imp.$chr
    done

    calc-g imp 17k-a.G
    cp gmat.id 17k-a.G.id
    cat 17k-a.G |
	$gmt/g2-3c 17k-a.G.id >a17k.G
}
