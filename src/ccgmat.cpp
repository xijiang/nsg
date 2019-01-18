#include <iostream>
#include <thread>
#include <vector>
/**
 * this version of G-matix calculator is to try to be more generic
 * that is, avoid limiting to requiring avx set 
 * also, add scenarios like using fixed allele frequency
 */
using namespace std;

int main(int argc, char *argv[])
{
  const int NG{6};		// number of gigabytes needed
  const int NDBL{NG*1024*1024*1024/8}; // number of genotypes in double 
  
  int nid, nlc;
  cin>>nid>>nlc;		// evaluate number of batches here
  if(nid*nlc

  double frq[nlc];
  for(auto&f:frq) cin>>f;

  string gt;
  for(string line; cin>>line; gt+=line);
  
  return 0;
}
