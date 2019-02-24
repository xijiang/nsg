#include <iostream>
#include <fstream>
#include <cmath>

/**
 * This is to calculate allele and genotype difference in two VCF files.
 * Aiming to find loci that are very poorly imputed
 *
 * Usage:
 *    ./imperr 1st.extracted 2nd.extracted >err.txt
 *
 * Output 3 columns in err.txt:
 *   SNP-name allele-freq-1st genotype-difference allele-difference
 */
using namespace std;

int main(int argc, char *argv[])
{
  if(argc!=3){
    cerr<<"Usage: "<<argv[0]<<" 1st-file 2nd-file\n";
    return 1;
  }
  ifstream foo(argv[1]), bar(argv[2]);
  string   sa, sb, ga, gb;
  while(foo>>sa>>ga){
    bar>>sb>>gb;
    if(sa!=sb){
      cerr<<"Locus not match: "<<sa<<' '<<sb<<'\n';
      return 2;
    }
    int eg{0}, ea{0}, ht{0}, ho{0};
    for(size_t i=0; i<ga.length(); ++i){
      if(ga[i] != gb[i]){
	++eg;
	if(ga[i]=='1') ++ht;
	else           ++ho;
      }
      ea += abs(ga[i]-gb[i]);
    }
    cout<<sa<<'\t'<<eg<<'\t'<<ea<<'\t'<<ht<<'\t'<<ho<<'\n';
  }
  
  return 0;
}
