calc-hdimp()
    cd $work

    # prepare LD genotypes in beagle format
    # link the available genotype files here
    for i in $G7327 $G600K; do
	ln -s $genotypes/$i .
    done
    
    # make ID info and map ready. NOTE: ID with LD ($4<5) genoyptes only
    cat $genotypes/$idinfo |
	gawk '{if(length($3)>5 && length($4<5)) print $3, $1}' >idinfo

    cat $maps/$map7327 | 
	gawk '{print $2, $1, $4}' > mapinfo

    $bin/mrg2bgl idinfo mapinfo $G7327
    for chr in {26..1}; do
	java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
	    gzip -c >ld.$chr.vcf.gz
    done

    # Prepare HD genotypes in beagle format
    # link the available genotype files here
    # make ID info and map ready
    cat $genotypes/$idinfo |
	gawk '{if(length($4)>5) print $4, $1}' >idinfo

    $bin/mrg2bgl idinfo mapinfo $G600K

    for chr in {26..1}; do
	java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
            gzip -c >hd.$chr.vcf.gz

	# vcfMrg
	# {1..26}.vcf.gz ld.{1..26}.vcf.gz ---> tmp.{1..26}.vcf.gz
	$bin/ljvcf <(zcat hd.$chr.vcf.gz) <(zcat ld.$chr.vcf.gz) |
	    gzip -c >tmp.$chr.vcf.gz
	
        java -jar $bin/beagle.jar \
             gt=tmp.$chr.vcf.gz \
             ne=$ne \
             out=imp.$chr
    done

    calc-g imp hd-only.G
    cp gmat.id hd-only.G.id
}
