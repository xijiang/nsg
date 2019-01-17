#include <iostream>
#include <sstream>
#include <fstream>
#include <map>
#include <vector>

using namespace std;

/**
 * Left Join VCF files (ljvcf)
 *   Only attach loci contained in the left vcf file, others as missing
 */

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false); // avoid significant overhead
  
  map<string, string> grht;
  vector<string>     idrht;
  {
    ifstream fin(argv[2]); 	// read the right hand vcf file first
    for(string line; getline(fin, line);)
      if(line.length()>100){	// the ID line;
	stringstream ss(line);
	string       id;
	for(auto i=0; i<9; ++i) ss>>id;
	while(ss>>id) idrht.push_back(id);
	break;
      }

    for(string dum, snp, gt;
	fin>>dum>>dum>>snp>>dum>>dum>>dum>>dum>>dum>>dum;
	getline(fin, gt))
      grht[snp]=gt;
  }

  // create a dummy genotype string
  string dummy(idrht.size()*4, '\t');
  for(size_t i=1; i<dummy.length(); i+=4){
    dummy[i] = dummy[i+2] = '.';
    dummy[i+1] = '/';
  }

  ifstream fin(argv[1]);	// Read the left hand vcf file
  for(string line; getline(fin, line);) // the header
    if(line[1]=='#') cout<<line<<'\n';
    else{
      cout<<line;
      break;
    }

  for(auto&id:idrht) cout<<'\t'<<id; // the ID
  cout<<'\n';

  for(string line; getline(fin, line);){
    cout<<line;
    stringstream ss(line);
    string       snp;
    ss>>snp>>snp>>snp;
    if(grht.find(snp)==grht.end()) cout<<dummy<<'\n';
    else                           cout<<grht[snp]<<'\n';
  }
    
  return 0;
}
