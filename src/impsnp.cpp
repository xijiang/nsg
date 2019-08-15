/**
 * cat ld.snp to this program
 * and the super SNP set file name as the argument.
 * e.g.,
 *     gawk '{print $1}' ld.map | ./impsnp <(gawk '{print $1}' hd.map) >imputed.snp
 */
#include <iostream>
#include <fstream>
#include <map>

using namespace std;

int main(int argc, char *argv[])
{
  set<string> small;
  for(string snp; cin>>snp; small.insert(snp));
  ifstream fin(argv[1]);
  for(string snp; fin>>snp;)
    if(small.find(snp) == small.end()) cout<<snp<<'\n';
  return 0;
}
