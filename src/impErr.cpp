#include <iostream>
#include <fstream>
#include <sstream>
#include <map>
#include <cmath>
/**
 * This is to calculate allele and genotype difference in two VCF files.
 * Aiming to find loci that are very poorly imputed
 *
 * Usage:
 *    ./imperr 1st.vcf 2nd.vcf >err.txt
 *
 * Output 3 columns in err.txt:
 *   SNP-name allele-freq-1st genotype-difference allele-difference
 */
using namespace std;

void parse_id(string&line, map<string, int>&ID){
  stringstream ss(line);
  string       id;
  for(auto i=0; i<9; ++i) ss>>id; // skip the first 9 columns
  int k{0};
  while(ss>>id) ID[id]=k++;	// ID name and their indices
}


void parse_gt(string&line, string&snp, string&gt){
  stringstream ss(line);
  string       dum;
  for(auto i=0; i<3; ++i) ss>>snp;
  for(auto i=0; i<6; ++i) ss>>dum;
  while(ss>>dum){		// just put the genotypes in a string
    gt+=dum[0];
    gt+=dum[2];
  }
}


int main(int argc, char *argv[])
{
  ifstream            f1st(argv[1]), f2nd(argv[2]);
  map<string, int>    ID, JD;	// two ID lists
  map<string, string> GT;

  for(string line; getline(f1st, line);)
    if(line[1] != '#'){		// ID in the first file
      parse_id(line, ID);
      break;
    }

  for(string line; getline(f1st, line);){
    string snp, gt;		// genotype in the first file
    parse_gt(line, snp, gt);
    GT[snp] = gt;
  }

  for(string line; getline(f2nd, line);)
    if(line[1] != '#'){		// ID in the second file
      map<string, int> TD;
      parse_id(line, TD);
      for(auto&[id, ix]:TD)	// clean non-shared ID from the 2nd file
	if(ID.find(id) != ID.end()) JD[id]=ix;
      break;
    }

  for(string line; getline(f2nd, line);){
    string snp, gt;
    parse_gt(line, snp, gt);	// Read a genotype line and compare
    if(GT.find(snp) == GT.end()) continue;
    
    int    gerr{0}, aerr{0}; 	// numbers of genotype and allele errors
    int    frq{0};
    string ft(GT[snp]);		// genotype of the same SNP in the 1st file
    for(auto&[id, ix]:ID){
      if(JD.find(id) == JD.end()) continue;
      auto jx(JD[id]);
      int g1(gt[ix] + gt[ix+1]);
      int g2(gt[jx] + gt[jx+1]);
      frq+=g1-'0'*2;
      if(g1 != g2){
	++gerr;
	aerr += abs(g1-g2);
      }
    }
    cout<<snp<<' '<<frq<<' '<<gerr<<' '<<aerr<<'\n';
  }
  
  return 0;
}
