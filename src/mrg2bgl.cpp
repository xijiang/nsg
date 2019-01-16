/**
 * this program read genotypes, hbn:sampleid, and map all together
 * output chr.mrk chr.bgl
 * discard duplicate ID and loci who have more missing alleles
 * Usage:
 *     prg map ID *txt(in final format)
 */
#include <iostream>
#include <fstream>
#include <sstream>
#include <map>
#include <set>
#include <tuple>
#include <vector>
#include <algorithm>

using namespace std;

using locus = tuple<string, int, string>;
using MSS=map<string, string>;
using VLC=vector<locus>;
using VST=vector<string>;


void readid(MSS&idmap, string file){
  // Read ID sample number and its herd book number
  ifstream fin(file);
  for(string sample, hbn; fin>>sample>>hbn;) idmap[sample]=hbn;
}


void readmp(VLC&lmap, string file){
  // Read {chr bp snp}
  ifstream fin(file);
  string   snp, chr;
  for(int bp; fin>>snp>>chr>>bp; ) lmap.push_back({chr, bp, snp});
}


void readrw(VST&ID, MSS&idmap, MSS&genotype, string file){
  // Read raw genotype data
  ifstream fin(file);
  string   line, vgg{"ACGT"};
  vector<bool> vid;

  for(auto row{0}; row<10; ++row) getline(fin, line);
  stringstream ss(line);
  for(string id; ss>>id;)	// Read and translate required ID
    if(idmap.find(id)!=idmap.end()){
      vid.push_back(true);
      ID.push_back(idmap[id]);
    }else vid.push_back(false);

  for(string snp; fin>>snp;){
    getline(fin, line);
    stringstream tt(line);
    string       aa;		// allele:allele
    for(const auto&p:vid){
      tt>>aa;
      if(aa.length()!=2) cerr<<"Invalid format (not biallelic) !!!\n";
      if(p){
	if(vgg.find(aa[0])==string::npos) aa[0]='-';
	if(vgg.find(aa[1])==string::npos) aa[1]='-';
	genotype[snp]+=aa;
      }
    }
  }
}


void putID(VST&ID){
  ofstream foo("gmat.id");
  for(const auto&id:ID) foo<<id<<'\n';
}



void putCHR(string chr, VST&ID, VLC&lmap, MSS&genotype){
  auto bp_pre{-1};
  ofstream mrk(chr+".mrk");
  ofstream bgl(chr+".bgl");

  bgl<<"I\tid";
  for(const auto&id:ID) bgl<<'\t'<<id<<'\t'<<id;
  bgl<<'\n';
  
  for(const auto&[cc, bp, snp]:lmap){
    if(cc!=chr)      continue;
    if(bp==bp_pre)   continue;
    bp_pre=bp;
    set<char> aa;
    for(const auto&a:genotype[snp])
      if(a!='-') aa.insert(a);
    if(aa.size()!=2) continue;
    bgl<<"M "<<snp;
    for(const auto&ch:genotype[snp]) bgl<<' '<<ch;
    bgl<<'\n';
    mrk<<snp<<' '<<bp;
    for(const auto&ch:aa) mrk<<' '<<ch;
    mrk<<'\n';
  }
}


int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false); // avoid significant overhead
  MSS idmap;			// map: sampleID -> herd book number
  readid(idmap, argv[1]);
  
  VLC lmap;			// vec: chr bp snp
  readmp(lmap, argv[2]);
  
  VST ID;
  MSS genotype;
  for(auto raw{3}; raw<argc; ++raw)
    readrw(ID, idmap, genotype, argv[raw]);
  
  // Output id order in G matrix
  putID(ID);
  
  // Output mrk and bgl files
  sort(lmap.begin(), lmap.end()); // tuple chr bp snp-name

  for(int ichr{1}; ichr<27; ++ichr)
    putCHR(to_string(ichr), ID, lmap, genotype);

  return 0;
}
