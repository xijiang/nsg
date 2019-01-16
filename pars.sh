# get genotypes groups, e.g, G7327, G600k
base=`pwd`

# Genotype files
source $base/data/genotypes/groups.sh

# Map files
source $base/data/maps/maps.sh

work=$base/work/`date +%Y-%m-%d-%H-%M-%S`
bin=$base/bin
dat=$base/data
genotypes=$dat/genotypes
maps=$dat/maps
