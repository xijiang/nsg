#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>

using namespace std;

int main(int argc, char *argv[])
{
  int            nid{0};
  vector<int>    frq;
  vector<string> gt;
  string         line;

  while(getline(cin, line)) if(line[0]!='#') break;
  {
    stringstream ss(line);
    for(string id; ss>>id; ++nid);
    nid -= 9;
  }

  while(getline(cin, line)){
    if(line[0]=='#') continue;
    string idg(nid*2, '-'), aa;
    int    i, j{0}, fq{0};
    stringstream ss(line);
    for(i=0; i<9; ++i) ss>>aa;
    for(i=0; i<nid; ++i){
      ss>>aa;
      idg[j++] = aa[0];
      idg[j++] = aa[2];
    }
    for(auto ch:idg) if(ch=='1') ++fq;
    gt.push_back(idg);
    frq.push_back(fq);
  }

  cout<<nid<<' '<<frq.size()<<'\n';
  for(auto&f:frq) cout<<f<<'\n';
  for(auto&s:gt ) cout<<s<<'\n';
  return 0;
}
