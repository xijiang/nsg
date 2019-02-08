# The NSG genomic selection project

## Usage:

In a bash terminal, run below
```bash
git clone https://github.com/xijiang/nsg

cd nsg

# Rum below for the first time, run prepare.sh first
./prepare.sh

# then run below to create various G matrices
nohup ./run-pipes.sh &
```

## Notes:

I made the code part public to ease the pipeline setup

The genotype data are stored somewhere else.  Without these data, these codes are almost useless.


## ToDo:

todo: change from HBN to animal ID

todo: use p=0.5

todo: kick out HD loci poorly imputed

todo: try MAF

todo: plot G of p=0.5 against others

todo: Understand G as per frequencies
