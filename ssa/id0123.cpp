#include <iostream>
#include <fstream>
#include <set>
#include <map>
#include <algorithm>

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  ifstream fin;
  map<int, int> dict;
  fin.open(argv[1]);
  for(int id, ix; fin>>id>>ix; dict[id]=ix);
  int psize(static_cast<int>(dict.size())); // pedigree size in integer
  fin.close();			// !!! dict then should not be modified.

  set<int> ph, gt;
  fin.open(argv[2]);
  for(int ix; fin>>ix; ph.insert(ix));
  fin.close();
  
  ofstream f3("3.id"), f2("2.id"), f1("1.id"), f0("0.id");
  fin.open(argv[3]);
  for(int id; fin>>id;)
    if(dict.find(id)!=dict.end()){
      int ix(dict[id]);
      if(ph.find(ix)!=ph.end()){
	f2<<ix<<'\n';
	gt.insert(ix);
      } else f3<<id<<'\n';
    } else f3<<id<<'\n';	// 2 & 3 not ordered

  for(const auto&ix:ph) if(gt.find(ix)==gt.end()) f1<<ix<<'\n'; // ordered
  for(int ix=1; ix<=psize; ++ix) if(ph.find(ix)==ph.end()) f0<<ix<<'\n'; // ordered

  return 0;
}
