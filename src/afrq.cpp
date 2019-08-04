#include <iostream>
#include <sstream>

using namespace std;

int main(int argc, char *argv[])
{
  int nid{-9};
  for(string line; getline(cin, line);) // header
    if(line[1]!='#'){
      stringstream ss(line);
      string tt;
      while(ss>>tt)++nid;
      break;
    }

  for(string line; getline(cin, line);){
    stringstream ss(line);
    string tt;
    for(auto i{0}; i<9; ++i) ss>>tt;
    double na{0};
    while(ss>>tt){
      if(tt[0]=='1') ++na;
      if(tt[2]=='1') ++na;
    }
    cout<<na/2/nid<<'\n';
  }
  return 0;
}
