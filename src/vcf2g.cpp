#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
/**
 * This is to convert VCF file from Beagle 5 imputation to genotype file
 * of my format.
 */
using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false); // avoid significant overhead
  int            nid{0};
  char           first;
  vector<int>    frq;
  vector<string> gt;
  string         line;

  while(cin>>first)		// determine number of ID
    if(first=='#') getline(cin, line);
    else{
      cin.putback(first);
      stringstream ss(line);
      for(string id; ss>>id; ++nid);
      nid -= 9;
      break;
    }

  while(getline(cin, line)){
    if(line[0]=='#') continue;	// if cat multiple files
    string idg(nid, '-'), aa;
    int    i, j{0}, fq{0};
    stringstream ss(line);
    for(i=0; i<9; ++i) ss>>aa;
    for(i=0; i<nid; ++i){
      ss>>aa;
      idg[j++] = aa[0] - '0' + aa[2];
    }
    for(auto ch:idg) fq+=(ch-'0');
    gt.push_back(idg);
    frq.push_back(fq);
  }

  cout<<nid<<' '<<frq.size()<<'\n';
  for(auto&f:frq) cout<<f<<'\n';
  for(auto&s:gt ) cout<<s<<'\n';
  return 0;
}
