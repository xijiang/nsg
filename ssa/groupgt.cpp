#include <iostream>
#include <sstream>
#include <fstream>
#include <map>

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  
  // Below two rows are to make sure the ID of training genotypes are right order 
  map<int, string> zt, zv;	// ID code, genotypes
  // zt: idx -> genotypes. combine idx -> ID ==> ID -> genotypes, in idx order
  // zv: ID -> genotypes. order is not important
  map<int, int> it, ti, ii, vi;
  // it: idx -> training ID, idx is the order in the absorption procedure
  // ti: reverse map of above
  // ii: idx-id -> idx-vcf index in ti to idx in vcf
  // vi: ID -> idx in the vcf file, idx is the column number
  
  ifstream fin;
  
  fin.open(argv[1]);		// training ID, record order
  for(int id, cc{1}; fin>>id; ++cc){
    it[cc] = id;
    ti[id] = cc;
  }
  fin.close();
  
  fin.open(argv[2]);
  for(int id; fin>>id;) vi[id] = 0; // order is not important
  fin.close();

  // ID columns in the vcf file
  int nid{0};
  for(string line; getline(cin, line);)
    if(line[1]!='#'){
      stringstream ss(line);
      string tmp;
      for(auto i{0}; i<9; ++i) ss>>tmp;
      for(int id; ss>>id; ++nid)
	if(vi.find(id) != ti.end()) vi[id]=nid;
	else ii[ti[id]] = nid;
      break;
    }

  // Initialize the two genotype containers
  for(const auto&[ix, id]:it) zt[ix]="";
  for(const auto&[id, ix]:vi) zv[id]="";
  
  string lc(nid, 'x');
  for(string line; getline(cin, line);){
    if(line[0]=='#') continue;
    stringstream ss(line);
    string tmp;
    for(auto i{0}; i<9; ++i) ss>>tmp;
    int ix{0};
    for(string aa; ss>>aa; ++ix) lc[ix]=aa[0]-'0'+aa[2];
    for(auto&[id, gt]:zt) gt += lc[ii[id]];
    for(auto&[id, gt]:zv) gt += lc[vi[id]];
  }

  // output the results
  ofstream foo;
  foo.open(argv[3]);
  for(const auto&[id, gt]:zt){
    foo<<it[id];
    for(const auto&c:gt) foo<<' '<<c;
    foo<<'\n';
  }
  foo.close();

  foo.open(argv[4]);
  for(const auto&[id, gt]:zv){
    foo<<id;
    for(const auto&c:gt) foo<<' '<<c;
    foo<<'\n';
  }
  foo.close();
  return 0;
}
