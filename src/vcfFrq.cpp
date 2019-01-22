#include <iostream>
#include <fstream>
#include <sstream>
#include <map>
#include <vector>
#include <algorithm>

/**
 * This is to calculate the heterozygosity of specified ID (from a file) in
 * a series of vcf files
 * Usage:
 *    zcat *vcf.gz | ./vcfFrq id-lst
 */

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  map<string, int> sid;		// the specified ID to be calculated
  vector<int>      cls;		// columns of specified ID
  string           line;
  {
    ifstream fin(argv[1]);
    for(string id; fin>>id; sid[id]=-1);

    for(;;){			// is this dirty?
      getline(cin, line);
      if(line[1] != '#') break;
    }
    stringstream ss(line);
    int nfd{-9};		// skip the first 9 description fields
    for(string rcd; ss>>rcd; ++nfd)
      if(sid.find(rcd) != sid.end()) sid[rcd]=nfd;

    for(auto&[id, ps]:sid)
      if(ps==-1) cerr<<id<<" is not in the VCF file, and is deleted\n";
      else       cls.push_back(ps);

    sort(cls.begin(), cls.end());
  }

  int    nlc{0};
  double hz{0};
  for(char ch; cin>>ch;){
    if(ch=='#'){
      getline(cin, line);
      continue;
    }
    cin.putback(ch);
    ++nlc;
    for(auto i=0; i<9; ++i) cin>>line;
    getline(cin, line);
    for(auto&p:cls)
      if(line[p*4+1] != line[p*4+3]) ++hz;
  }
  cout<<hz/nlc/cls.size()<<'\n';
  return 0;
}
