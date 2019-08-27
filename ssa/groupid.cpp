/**
 * This is to translate animalID to coded ID according ped.dict
 */
#include <iostream>
#include <fstream>
#include <map>

using namespace std;

int main(int argc, char *argv[])
{
  map<int, int> code;
  ifstream fin(argv[1]);
  ofstream ftr(argv[2]), fvd(argv[3]);
  
  for(int id, v; fin>>id>>v; code[id]=v);

  for(int id; cin>>id;)
    if(code.find(id)!=code.end()) ftr<<id<<'\t'<<code[id]<<'\n';
    else fvd<<id<<'\n';		// for sub- genotype set later
    
  return 0;
}
