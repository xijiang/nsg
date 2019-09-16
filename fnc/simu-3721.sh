# This is a simulation test about the usability of the LD chip
# Using the non-shared autosomal loci as QTL,
# I then mask the BV of the latest animal
# and predict them using the shared LD&HD loci

prepare-a-directory(){
    work=$base/work/simulation
    mkdir -p $work
    cd $work

    for i in $G7327 $G600K; do
	    ln -sf $genotypes/$i
    done
}


prepare-loci(){
    cat $maps/$map7327 |
	    gawk
}



simulation(){
    prepare-a-directory
    
    prepare-loci
}
