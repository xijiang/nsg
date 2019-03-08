# The NSG genomic selection project

## Usage:

In a bash terminal, run below
```bash
git clone https://github.com/xijiang/nsg

cd nsg

# Rum below for the first time, run prepare.sh first
./prepare.sh

# then run below to create various G matrices
nohup ./run-the-pipe.sh &
```

## Notes:

I made the code part public to ease the pipeline setup

The genotype data are stored somewhere else.  Without these data, these codes are almost useless.


## ToDo:

1. Appraise 17k and 50k panels
2. Simulation and estimate GEBV
