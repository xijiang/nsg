#include <iostream>
#include <thread>
#include <vector>
#include <tuple>

/**
 * this version of G-matix calculator is to try to be more generic
 * that is, avoid limiting to requiring avx set 
 * also, add scenarios like using fixed allele frequency
 */
using namespace std;

using triple=tuple<double, double, double>

int main(int argc, char *argv[])
{
  int nid, nlc;
  cin>>nid>>nlc;

  double frq[2][nlc];
  for(auto &p:frq){
    cin>>p;
    p=

  double gtp[nid][nlc];
  string line;
  for(auto i=0; i<nlc; ++i){
    cin>>line;
    for(auto j=0; j<nid; ++j) gtp[j][i] = line[j]-'0';
  }

  
    
  return 0;
}


//  // I deal with 6G genotypes in double precision a time.
//  const int NG{6};		// number of gigabytes needed
//  const int NDBL{NG*1024/8*1024*1024}; // number of genotypes in double 
//  
//  int nid, nlc;
//  cin>>nid>>nlc;		// evaluate number of batches here
//  if(nid*nlc > NDBL)
//    cout<<"multiple batches needed\n";
//
//  double frq[nlc];
//  for(auto&f:frq) cin>>f;
//
//  string gt;
//  for(string line; cin>>line; gt+=line);
