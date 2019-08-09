/**
 * This is specially for the NSG pedigree file, which has 4 columns
 *   ID Pa Ma birth-year
 * I sort first on year, then on the ID, Pa, and Ma number
 *
 * Output:
 * to stdout:
 *    pa ma
 * to stdlog
 *    ID code
 *
 * Usage:
 *    cat pedigree | ./argv[0] >sorted.ped 2>ped.dic
 */

#include <iostream>
#include <tuple>
#include <algorithm>
#include <vector>
#include <map>

using namespace std;
using I4=tuple<int, int, int, int>;
using VI=vector<I4>;
using MI=map<int, int>;

int main(int argc, char *argv[])
{
  VI ped;
  for(int id, pa, ma, yr; cin>>id>>pa>>ma>>yr; ped.push_back({yr,id,pa,ma}));
  sort(ped.begin(), ped.end());

  MI  dic;
  int no{0};
  dic[0]=0;
  for(auto&[yr,id,pa,ma]:ped){	// code ID, and output coded pedigree [pa ma]xN
    dic[id] = no++;
    if(dic.find(pa)==dic.end()) dic[pa] = 0;
    if(dic.find(ma)==dic.end()) dic[ma] = 0;
    cout<<dic[pa]<<'\t'<<dic[ma]<<'\n';
  }

  for(auto&[id, code]:dic) clog<<id<<'\t'<<code<<'\n';
  return 0;
}

