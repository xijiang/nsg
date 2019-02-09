#include <iostream>
#include <fstream>
#include <sstream>
#include <map>

using namespace std;


void parse_id(string&line, map<string, int>&ID){
  stringstream ss(line);
  string       id;
  for(auto i=0; i<9; ++i) ss>>id;
  int k{0};
  while(ss>>id) ID[id]=k++;
}


void parse_gt(string&line, string&snp, string&gt){
  stringstream ss(line);
  string       dum;
  for(auto i=0; i<3; ++i) ss>>snp;
  for(auto i=0; i<6; ++i) ss>>dum;
  while(ss>>dum){
    gt+=dum[0];
    gt+=dum[2];
  }
}


int main(int argc, char *argv[])
{
  ifstream            f345(argv[1]), fimp(argv[2]);
  map<string, int>    ID, JD;	// two ID lists
  map<string, string> GT;

  for(string line; getline(f345, line);)
    if(line[1] != '#'){
      parse_id(line, ID);
      break;
    }

  for(string line; getline(f345, line);){
    string snp, gt;
    parse_gt(line, snp, gt);
    GT[snp] = gt;
  }

  for(string line; getline(fimp, line);)
    if(line[1] != '#'){
      map<string, int> TD;
      parse_id(line, TD);
      for(auto&[id, ix]:TD)
	if(ID.find(id) != ID.end()) JD[id]=ix;
      break;
    }

  for(string line; getline(fimp, line);){
    string snp, gt;
    parse_gt(line, snp, gt);
    if(GT.find(snp) == GT.end()) continue;
    
    int    err{0};
    string ft(GT[snp]);
    for(auto&[mrk, ix]:ID){
      auto jx(JD[mrk]);
      if(gt[jx] + gt[jx+1] != ft[ix] + ft[ix+1]) ++err;
    }
    cout<<snp<<' '<<err<<'\n';
  }
  
  return 0;
}
