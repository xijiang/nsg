#include <iostream>
#include <fstream>
/**
 * This is to paste diagonals of Gs of a same dimension into diag.cols
 * and off-diagonals into off.cols
 */
using namespace std;

int main(int argc, char *argv[])
{
  int      nf(argc-1);
  int      nid[nf];
  double   td;
  ifstream fin[nf];
  ofstream diag("diag.cols"), off("off.cols");

  for(auto k=0; k<nf; ++k){
    fin[k].open(argv[k+1]);
    fin[k]>>nid[k];
    fin[k].ignore();
  }

  for(auto k{1}; k<nf; ++k)
    if(nid[k]!=nid[0]){
      cerr<<"Of different dimensions. Existing ...\n";
      return 1;
    }
  
  for(auto i{0}; i<nid[0]; ++i){
    for(auto j{0}; j<i; ++j){
      for(auto k{0}; k<nf; ++k){
	fin[k].read((char*)&td, sizeof(double));
	off<<'\t'<<td;
      }
      off<<'\n';
    }
    for(auto k{0}; k<nf; ++k){
      fin[k].read((char*)&td, sizeof(double));
      diag<<'\t'<<td;
    }
    diag<<'\n';
  }
  
  return 0;
}
