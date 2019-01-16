calc-g(){
    # This is always done in a sub folder, so $bin
    $bin/vcf2g <(gunzip -c $1.1.vcf.gz) \
               <(gunzip -c $1.2.vcf.gz) \
               <(gunzip -c $1.3.vcf.gz) \
               <(gunzip -c $1.4.vcf.gz) \
               <(gunzip -c $1.5.vcf.gz) \
               <(gunzip -c $1.6.vcf.gz) \
               <(gunzip -c $1.7.vcf.gz) \
               <(gunzip -c $1.8.vcf.gz) \
               <(gunzip -c $1.9.vcf.gz) \
               <(gunzip -c $1.10.vcf.gz) \
               <(gunzip -c $1.11.vcf.gz) \
               <(gunzip -c $1.12.vcf.gz) \
               <(gunzip -c $1.13.vcf.gz) \
               <(gunzip -c $1.14.vcf.gz) \
               <(gunzip -c $1.15.vcf.gz) \
               <(gunzip -c $1.16.vcf.gz) \
               <(gunzip -c $1.17.vcf.gz) \
               <(gunzip -c $1.18.vcf.gz) \
               <(gunzip -c $1.19.vcf.gz) \
               <(gunzip -c $1.20.vcf.gz) \
               <(gunzip -c $1.21.vcf.gz) \
               <(gunzip -c $1.22.vcf.gz) \
               <(gunzip -c $1.23.vcf.gz) \
               <(gunzip -c $1.24.vcf.gz) \
               <(gunzip -c $1.25.vcf.gz) \
               <(gunzip -c $1.26.vcf.gz) |
    $bin/bpxvr1g > $2
}

