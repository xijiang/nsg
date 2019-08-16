/**
 * read ID to mask and marker names on a sparse chip
 * Do the mask and output the masked vcf stream to stdout.
 */
#include <iostream>
#include <fstream>
#include <sstream>
#include <random>
#include <set>
#include <vector>
#include <algorithm>

using namespace std;

int main(int argc, char *argv[])
{
  if(argc!=3){
    cerr<<"Usage:\n";
    cerr<<"zcat chr.vcf.gz | " <<argv[0]<<" id-bool snp-list\n";
    return 1;
  }
  vector<int> mid;		// ID to be masked 0 to mask, 1 not to mask
  ifstream fin(argv[1]);
  for(int x; fin>>x; mid.push_back(x));
  fin.close();

  fin.open(argv[2]);
  set<string> ld;
  for(string snp; fin>>snp; ld.insert(snp));

  for(string line; getline(cin, line);){
    cout<<line<<'\n';
    if(line[1]!='#') break;	// Break @ the ID line
  }

  for(string line; getline(cin, line);){
    stringstream ss(line);
    int          chr, pos;
    string       snp;
    ss>>chr>>pos>>snp;
    if(ld.find(snp)==ld.end()) cout<<line<<'\n';
    else{
      cout<<chr<<'\t'<<pos<<'\t'<<snp;
      string tt;
      for(auto i=0; i<6; ++i){
	ss>>tt;
	cout<<'\t'<<tt;
      }
      for(auto&x:mid){
	ss>>tt;
	x ? cout<<'\t'<<tt : cout<<"\t./.";
      }
      cout<<'\n';
    }
  }
    
  return 0;
}
