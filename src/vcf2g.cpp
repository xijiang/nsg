#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>

using namespace std;

int main(int argc, char *argv[])
{
  int    nid(stoi(argv[1])), nlc{0};
  vector<int>    frq;
  vector<string> gt;

  for(string line; getline(cin, line);){
    if(line[0]=='#') continue;
    ++nlc;
    stringstream ss(line);
    string aa, cg;
    int    fq{0};
    for(auto i=0; i<9; ++i) ss>>aa;
    while(ss>>aa){
      int ch;
      ch = aa[0]-'0'+aa[2];
      fq+=int(ch-'0');
      cg+=ch;
    }
    gt.push_back(cg);
    frq.push_back(fq);
  }

  cout<<nid<<' '<<nlc<<'\n';
  for(auto&f:frq) cout<<f<<'\n';
  for(auto&s:gt ) cout<<s<<'\n';
  return 0;
}
