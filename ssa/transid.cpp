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
  for(int id, tt; fin>>id>>tt; code[id]=tt);

  for(int id; cin>>id;)
    if(code.find(id)!=code.end()) cout<<code[id]<<'\n';
    else clog<<id<<" not found in the dictionary\n";
    
  return 0;
}
