#include <iostream>
#include <fstream>
#include <set>

using namespace std;

/**
 * Read a map of SNP-name, chr, and bp
 * Output a submap if SNP-name is in a predefined set
 */

int main(int argc, char *argv[])
{
  if(argc!=2){
    cerr<<"Usage: "<<argv[0]<<" snp-set\n";
    return 1;
  }
  set<string> osnp;
  {
    ifstream fin(argv[1]);
    for(string snp; fin>>snp; osnp.insert(snp));
  }

  string snp, chr, bp;
  while(cin>>snp>>chr>>bp)
    if(osnp.find(snp)!=osnp.end())
      cout<<snp<<'\t'<<chr<<'\t'<<bp<<'\n';
  
  return 0;
}
