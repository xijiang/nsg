#include <iostream>
#include <fstream>
#include <vector>
#include <sstream>
#include <map>

/**
 * This is to do a simple statistics about VCF file(s)
 * 1. No-ID, and put ID into vcf.ID, and in order of they appeared in VCF
 * 2. No-SNP, and put SNP into vcf.SNP, keep their original order
 * 3. Missing loci rates, missing in over 50% ID, fixed loci
 
 * Usage: zcat {1..26}.vcf.gz | ./vcfstat
 */

using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  vector<string> ID, SNP;
  map<string, int> err;

  for(string line; getline(cin, line);){
    if(line[1] == '#') continue;
    stringstream ss(line);
    if(line[0] == '#'){
      stringstream ss(line);
      string id;
      for(auto i{0}; i<9; ++i) ss>>id;  //dummy
      if(ID.size()){
        for(const auto&jd:ID){
          ss>>id;
          if(id != jd){
            cerr<<"ID don't match\n";
            return 1;
          }
        }
      }
      else while(ss>>id) ID.push_back(id);
    }else
    {
      string snp, gt;
      ss>>snp>>snp>>snp;
      SNP.push_back(snp);
      for(auto i{0}; i<6; ++i) ss>>snp;
      for(const auto&id:ID){
        ss>>gt;
        if(gt[0]=='.') ++err[snp];
        if(gt[2]=='.') ++err[snp];
      }
    }
  }
  /* Report */
  int nid = static_cast<int>(ID.size());
  int nlc = static_cast<int>(SNP.size());
  ofstream foo("vcf.ID");
  for(const auto&id:ID) foo<<id<<'\n';
  foo.close();
  foo.open("vcf.SNP");
  for(const auto&snp:SNP) foo<<snp<<'\n';
  foo.close();

  clog<<"There are "<<nid<<" ID. See vcf.ID for details\n";
  clog<<"There are "<<nlc<<" SNP. See vcf.SNP for details\n\n";

  int ter{0};
  for(const auto&[snp, cnt]:err){
    ter+=cnt;
    if(cnt>nid) clog<<snp<<' '<<cnt<<'\n';
  }
  clog<<"There are "<<ter<<" total missing alleles. Loci with >50% missing are listed above\n";
 
  return 0;
}
