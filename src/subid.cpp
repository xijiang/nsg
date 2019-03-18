#include <iostream>
#include <set>
#include <vector>
#include <fstream>
#include <sstream>

/**
 * Given a VCF file A, create another VCF file whose ID are a subset of A
 */

using namespace std;

int main(int argc, char *argv[])
{
  if(argc!=2){
    cerr<<"Usage: "<<"zcat vcf.gz | "<<argv[0]<<" id.lst\n";
    return 1;
  }
  
  set<string> ID;
  {
    ifstream fin(argv[1]);
    for(string id; fin>>id; ID.insert(id));
  }

  vector<int> oo;
  for(string line; getline(cin, line);)
    if(line[0]=='#')
      if(line[1]=='#') cout<<line<<'\n';
      else{
	stringstream ss(line);
	string id;
	ss>>id;
	cout<<id;
	for(auto i=1; i<9; ++i){
	  ss>>id;
	  cout<<'\t'<<id;
	}
	while(ss>>id)
	  if(ID.find(id)!=ID.end()){
	    cout<<'\t'<<id;
	    oo.push_back(1);
	  }else oo.push_back(0);
	cout<<'\n';
      }
    else{
      string gt;
      stringstream ss(line);
      ss>>gt;
      cout<<gt;
      for(auto i=1; i<9; ++i){
	ss>>gt;
	cout<<'\t'<<gt;
      }
      for(auto&q:oo){
	ss>>gt;
	if(q) cout<<'\t'<<gt;
      }
      cout<<'\n';
    }
  
  return 0;
}
