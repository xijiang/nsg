calc-ga17k(){
    # Create a separate work space
    date
    echo Prepare directory and files
    work=$base/work/a17k.g
    mkdir -p $work/{pre,imp}
    cd $work/pre

    # link the available genotype files here
    gfiles=`ls $genotypes/a17k/`
    ln -s $genotypes/a17k/* .
    
    # make ID info and map ready
    tail -n+2 $ids/id.lst |
	gawk '{if(length($6)>2 && $9==10 && $7>1999) print $6, $2}' >idinfo
    
    cat $maps/a17k.map | 
	gawk '{print $2, $1, $4}' > mapinfo

    $bin/mrg2bgl idinfo mapinfo $gfiles

    date
    echo Impute the missing genotypes
    for chr in {26..1}; do
    	java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
            gzip -c >$chr.vcf.gz

        java -jar $bin/beagle.jar \
             gt=$chr.vcf.gz \
             ne=$ne \
             out=../imp/$chr
    done

    date
    echo Calculate G matrix
    cd ../imp
    zcat {1..26}.vcf.gz |
	$bin/vcf2g |
	$bin/vr1g >../17k-a.G

    mv ../pre/gmat.id ../17k-a.G.id

    cd ..
    cat 17k-a.G |
	$bin/g2-3c 17k-a.G.id >17k-a.3c
}
