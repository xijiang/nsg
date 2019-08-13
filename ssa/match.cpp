/**
 * This is to match ID in phenotypes with those in the dictionary
 */
#include <iostream>
#include <fstream>
#include <map>
#include <vector>
#include <algorithm>

using namespace std;

int main(int argc, char *argv[])
{
  map<int, int> code;
  ifstream      fdic(argv[1]);
  int           id;
  for(int tt; fdic>>id>>tt; code[id]=tt);

  for(double ebv, err; cin>>id>>ebv>>err;)
    if(code.find(id)!=code.end()) cout<<code[id]<<'\t'<<ebv<<'\t'<<err<<'\n';
    else cerr<<id<<" Was not found in the pedigree\n";
    
  return 0;
}
