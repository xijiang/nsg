#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <set>
#include <map>

using namespace std;

int main(int argc, char *argv[])
{
  if(argc!=3){			// show usage 
    cerr<<"Usage: zcat pre.{1..26}.vcf.gz | "<<argv[0]<<" id-list imputed-SNP >pre.g\n";
    return 1;
  }
  set<string> imputed;		// input shared markers
  {
    ifstream fin(argv[2]);
    for(string mrk; fin>>mrk; imputed.insert(mrk));
  }
  map<string, int> ID;
  int              nid{-9};
  {
    ifstream fin(argv[1]);	// id list whose genotypes to output
    for(string id; fin>>id; ID[id]=0);

    // determine ID list and order with the 1st chromosome
    for(string line; getline(cin, line);){
      if(line[1]=='#') continue;
      stringstream ss(line);
      string id;
      size_t oid{0};
      while(ss>>id){
	if(ID.find(id)!=ID.end()){
	  ID[id] = nid;
	  ++oid;
	}
	++nid;
      }
      if(oid!=ID.size()){
	cout<<"Some ID are not in the vcf files\n";
	return 2;
      }
      break;
    }
  }
  
  string ogt(nid, '0');
  for(string line; getline(cin, line);){
    if(line[0]=='#') continue;
    stringstream ss(line);
    string snp, gt;
    ss>>snp>>snp>>snp;
    if(imputed.find(snp)==imputed.end()) continue;
    for(auto i{0}; i<6; ++i) ss>>gt; // skip the first 9 columns
    for(auto i{0}; i<nid; ++i){
      ss>>gt;
      ogt[i] = gt[0]-'0'+gt[2];
    }
    cout<<snp<<' ';
    for(auto&[id, ix]:ID)cout<<ogt[ix];
    cout<<'\n';
  }
    
  return 0;
}
