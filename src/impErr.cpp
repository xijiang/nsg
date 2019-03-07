#include <iostream>
#include <cmath>
/**
 * This is to calculate allele and genotype difference in two VCF files.
 * Aiming to find loci that are very poorly imputed
 *
 * Usage:
 *    paste snp.chr ref imp | ./impErr >err.txt
 *
 * Output 6 columns in err.txt:
 *   1) SNP name
 *   2) chromosome number
 *   3) allele frequency from reference
 *   4) genotype difference
 *   5) allele difference
 *   6) heterozygotes imputed to homozygotes
 */
using namespace std;

int main(int argc, char *argv[])
{
  string snp, ga, gb;
  int    chr;
  while(cin>>snp>>chr>>ga>>gb){
    cout<<snp<<'\t'<<chr;
    int frq{0}, eg{0}, ea{0}, ht{0};
    for(size_t i=0; i<ga.length(); ++i){
      frq += (ga[i]-'0');
      if(ga[i] != gb[i]){
	++eg;
	if(ga[i]=='1') ++ht;
      }
      ea += abs(ga[i]-gb[i]);
    }
    cout<<'\t'<<frq<<'\t'<<eg<<'\t'<<ea<<'\t'<<ht<<'\n';
  }
  
  return 0;
}
