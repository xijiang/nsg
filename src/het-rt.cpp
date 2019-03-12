#include <iostream>
#include <vector>
#include <sstream>
#include <cmath>

using namespace std;

/**
 * Read imputed genotypes (no missing genotypes) in VCF format
 * Calulate log(het) rate for every ID
 */

int main(int argc, char *argv[])
{
  vector<string> ID;
  string line;
  size_t i;
  while(getline(cin, line))
    if(line[1]!='#'){		// ID names from the 1st chromosome
      stringstream ss(line);
      string id;
      for(i=0; i<9; ++i) ss>>id;
      while(ss>>id) ID.push_back(id);
      break;
    }

  int    nlc{0};
  double het[ID.size()];
  for(auto&p:het) p=0;
  
  while(getline(cin, line)){
    if(line[0]=='#') continue;
    stringstream ss(line);
    string gt;
    for(i=0; i<9; ++i) ss>>gt;
    for(i=0; i<ID.size(); ++i){
      ss>>gt;
      if(gt[0]!=gt[2]) ++het[i];
    }
    ++nlc;
  }

  for(i=0; i<ID.size(); ++i)
    cout<<ID[i]<<'\t'<<log(het[i]/nlc)<<'\n';

  return 0;
}
