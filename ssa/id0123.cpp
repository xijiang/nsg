#include <iostream>
#include <fstream>
#include <set>
#include <map>
#include <algorithm>

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  if(argc!=4){
    cerr<<"Usage:\n";
    cerr<<"\t"<<argv[0]<<" nid phenotyped-ID-list genotyped-ID-list\n";
    return 1;
  }
  int nid(stoi(argv[1]));	// number of ID
  set<int> idy;{		// ID with phenotypes
    ifstream fin(argv[2]);
    for(int id; fin>>id; idy.insert(id));
  }
  set<int> idg;{		// ID with genotypes
    ifstream fin(argv[3]);
    for(int id; fin>>id; idg.insert(id));
  }
  int n0{0};{			// ID w/o geno-, pheno-types
    ofstream foo("0.id");
    for(int id=1; id<=nid; ++id)
      if(idy.find(id)==idy.end() && idg.find(id)==idg.end()){
	foo<<id<<'\n';
	++n0;
      }
  }
  int n1{0};{			// ID with phenotypes, w/o genotypes
    ofstream foo("1.id");
    for(const auto&id:idy) if(idg.find(id)==idg.end()){
	foo<<id<<'\n';
      }
  }
  {				// the design matrix of X2
    ofstream f2("2.id"), f3("3.id");
    for(auto id:idg)
      if(idy.find(id)==idy.end()) f2<<id<<'\n';
      else                        f3<<id<<'\n';
  }

  return 0;
}
