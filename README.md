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

# Data requirements
1. three folders
   - genotyps: put genotypes in folder 600k, 7327, a17k, b17k, and gbs inside this folder
   - ids: put ID descriptions in this folder.
     * The description file can be of any name, but the current one to be used must be soft linked to id.lst
     * id.lst must of the following format
       - a head line: describing the name of each field
       - the columns are in the following order:
         1. Herdbook_number
         2. AnimalID
         3. SampleID_LD
         4. SampleID_HD
         5. SampleID_17Kbeta
         6. SampleID_17K
         7. BirthYear
         8. BreedGroup
         9. Breed
         10. Gender


