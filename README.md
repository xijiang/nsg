# NSG project
This is to impute genotypes and construct a G matrix

## Usage:

In a bash terminal, run below
```bash
git clone https://github.com/xijiang/nsg
cd nsg
git submodule init
git submodule update  # to fetch genotype data and other modules

# if you are running for the first time, run prepare.sh first
./prepare.sh

# then run below to create various G matrices
nohup ./run-pipes.sh &
```

