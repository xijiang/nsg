calc-g7327(){
    # Create a separate work space
    #work=$base/work/`date +%Y-%m-%d-%H-%M-%S`
    work=$base/work/7327.g
    mkdir -p $work
    cd $work

    # link the available genotype files here
    gfiles=`ls $genotypes/7327/`
    ln -s $genotypes/7327/* .
    
    # make ID info and map ready
    tail -n+2 $ids/id.lst |
	gawk '{if(length($3)>2 && $9==10 && $7>1999) print $3, $2}' >idinfo
    
    cat $maps/7327.map | 
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

    calc-g imp ld-only.G
    cp gmat.id ld-only.G.id
    cat ld-only.G |
	$gmt/g2-3c ld-only.G.id >7327.3c
}
