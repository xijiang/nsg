#include <iostream>
#include <fstream>
#include <map>
/**
 * To get the BLUP ebv from litter.pht
 */
using namespace std;

int main(int argc, char *argv[])
{
  map<int, double> blup;
  int id;
  double ebv;
  while(cin>>id>>ebv){
    blup[id] = ebv;
    cin>>ebv;
  }
  ifstream fin(argv[1]);
  while(fin>>id) cout<<blup[id]<<'\n';
  return 0;
}
