#include <iostream>
#include <sstream>
#include <fstream>
#include <map>

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  if(argc!=2){
    cerr<<"Usage:\n";
    cerr<<"\tzcat pathto/{1..26}.vcf.gz | "<<argv[0]<<" dictionary\n";
    return 1;
  }
  
  // Below two rows are to make sure the ID of training genotypes are right order
  map<int, int> dict;{
    ifstream fin(argv[1]);
    for(int id, ix; fin>>id>>ix; dict[id]=ix);
  }
  
  map<int, int>    ti, vi;
  map<int, string> zt, zv;	// ID/code -> genotypes
  int gid{0};			// number of genotyped animals
  for(string line; getline(cin, line);)
    if(line[1]!='#'){
      stringstream ss(line);
      string tmp;
      for(auto i=0; i<9; ++i) ss>>tmp;
      for(int id; ss>>id; ++gid)
	if(dict.find(id) != dict.end()){
	  int ix=dict[id];
	  ti[ix] = gid;
	  zt[ix] = "";
	}else{
	  vi[id] = gid;
	  zv[id] = "";
	}
      break;
    }
  
  string lc(gid, 'x');
  for(string line; getline(cin, line);){
    if(line[0]=='#') continue;
    stringstream ss(line);
    string tmp;
    for(auto i{0}; i<9; ++i) ss>>tmp;
    int ic{0};
    for(string aa; ss>>aa; ++ic) lc[ic]=aa[0]-'0'+aa[2];
    for(auto&[ix, gt]:zt) gt += lc[ti[ix]];
    for(auto&[id, gt]:zv) gt += lc[vi[id]];
  }
			 
  // output the results
  ofstream foo;
  foo.open("t.gt");
  for(const auto&[ix, gt]:zt){
    foo<<ix;
    for(const auto&c:gt) foo<<' '<<c;
    foo<<'\n';
  }
  foo.close();

  foo.open("v.gt");
  for(const auto&[id, gt]:zv){
    foo<<id;
    for(const auto&c:gt) foo<<' '<<c;
    foo<<'\n';
  }
  foo.close();
  return 0;
}
