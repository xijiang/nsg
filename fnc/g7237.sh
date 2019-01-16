#!/usr/bin/env bash

calc-g7327(){
    mkdir -p $work
    cd $work

    # link the available genotype files here
    for i in $G7327; do
	ln -s $genotypes/$i .
    done
    
    # make ID info and map ready
    cat $genotypes/$idinfo |
	gawk '{if(length($3)>5) print $3, $1}' >idinfo

    cat $maps/$map7327 | 
	gawk '{print $2, $1, $4}' > mapinfo

    $bin/mrg2bgl idinfo mapinfo $G7327

    for chr in {26..1}; do
	java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
            gzip -c >tmp.$chr.vcf.gz

        java -jar $bin/beagle.jar \
             gt=tmp.$chr.vcf.gz \
             ne=$ne \
             out=imp.$chr
    done

    #calc-g imp ld-only.G
    cp gmat.id ld-only.G.id
}
