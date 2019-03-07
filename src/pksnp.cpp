#include <iostream>
#include <set>
#include <fstream>
/**
 * read SNP1, chr from stdin
 * read SNP2 from argv[1]
 * output SNP1, chr if SNP1 is in SNP2
 */
using namespace std;

int main(int argc, char *argv[])
{
  if(argc!=2){
    cerr<<"Usage: cat {snp chr}_n | "<<argv[0]<<" {snp_set}\n";
    return 1;
  }
  set<string>SNP;		// the SNP to be checked
  {
    ifstream fin(argv[1]);
    for(string snp; fin>>snp; SNP.insert(snp));
  }
  
  string snp;
  int    chr;
  while(cin>>snp>>chr)		// set of SNP, chr to be picked up
    if(SNP.find(snp)!=SNP.end())
      cout<<snp<<' '<<chr<<'\n';
  
  return 0;
}
