#include <iostream>
#include <fstream>
#include <vector>
#include <map>

/**
 * Usage:
 *   submat source.G source.G.id sub.id target.G
 * This is to take a sub G matrix from another one
 * Re-order the ID in the order of sub.id
 * Results are put to target.G and target.G.id
 */

using namespace std;

int main(int argc, char *argv[])
{
  if(argc!=5){
    cerr<<"Usage: "<<argv[0]<<" src-G src-G.id tgt.id tgt.G\n";
    return 1;
  }
  
  int nid;			// number of ID in source G matrix
  ifstream ori(argv[1]);
  ori>>nid;
  ori.ignore();

  double G[nid][nid];		// the source G matrix
  for(auto i=0; i<nid; ++i)
    for(auto j=0; j<=i; ++j){
      double td;
      ori.read((char*)&td, sizeof(double));
      G[i][j] = G[j][i] = td;
    }

  map<string, int> ID;		// ID names in the source matrix
  {				//   and in this order
    int ix{0};
    ifstream fin(argv[2]);
    for(string id; fin>>id; ++ix) ID[id]=ix;
    if(ID.size()!=static_cast<size_t>(nid)){
      cerr<<"ID list and G don't match !!!\n";
      return 1;
    }
  }
  
  vector<int> lst;		// target ID list
  {
    ifstream fin(argv[3]);
    ofstream foo(string(argv[4])+".id");
    for(string id; fin>>id;){
      if(ID.find(id)==ID.end()) clog<<id<<" not found in "<<argv[2]<<'\n';
      else{
	lst.push_back(ID[id]);
	foo<<id<<'\n';
      }
    }
  }

  {
    ofstream foo(argv[4]);
    foo<<lst.size()<<'\n';
    for(size_t i=0; i<lst.size(); ++i)
      for(size_t j=0; j<=i; ++j)
	foo.write((char*)&(G[lst[i]][lst[j]]), sizeof(double));
  }
  
  return 0;
}
