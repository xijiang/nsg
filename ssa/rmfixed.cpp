#include <iostream>
#include <fstream>
#include <algorithm>

using namespace std;
bool isSpace(char ch){
  return ch==' ' || ch=='\t';
}

int main(int argc, char *argv[])
{
  if(!(argc==3 || argc==2)){
    cerr<<"Usage:\n\t";
    cerr<<argv[0]<<" training.gt validation.gt[op]\n";
    return 1;
  }
  string gt;
  int nid{0}, nlc;
  ifstream ft(argv[1]);
  // Input genotypes for training, determin nid, and nlc
  for(string line; getline(ft, line); ++nid){
    line.erase(remove_if(line.begin(), line.end(), isSpace), line.end());
    gt+=line;
  }
  nlc = gt.length()/nid;
  // Determine which loci are fixed
  int cnt[nlc]{0};
  for(auto i=0; i<nid; ++i)
    for(auto j=0; j<nlc; ++j) cnt[j] += gt[i*nlc+j]-'0';
  for(auto&a:cnt) if(a==nid*2) a=0; // 0 to discard, non-0 to keep

  // Output cleaned training genotypes
  ofstream ot(string(argv[1])+".cln");
  int i{0};
  for(const auto&a:gt){
    if(cnt[i++]) ot<<' '<<a;
    if(i==nlc){
      i=0;
      ot<<'\n';
    }
  }

  // If validation genotypes are to be cleaned, 2 arguments at command line
  if(argc==3){
    ifstream fv(argv[2]);
    ofstream ov(string(argv[2])+".cln");
    i=0;				// not necessary, as set 0 in above block
    for(char a; fv>>a;){
      if(cnt[i++]) ov<<' '<<a;
      if(i==nlc){
	i=0;
	ov<<'\n';
      }
    }
  }
  return 0;
}
