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

Since the genotypes and maps part are private, I stored them at some separate place.  Copy them under this nsg directory, and name the directory `data'.

## ToDo:

