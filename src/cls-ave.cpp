#include <iostream>
using namespace std;
/**
 * Given two columns:
 *   1. year
 *   2. VAR
 * this program calculate average 'VAR' on 'year'
 * this can also server as a general average (column 2) on class (column 1) prog
 */

int main(int argc, char *argv[])
{
  string cls, tmp;
  int    n{0};
  double var, acc{0};
  while(cin>>tmp>>var){
    if(tmp!=cls){
      if(n) cout<<cls<<'\t'<<acc/n<<'\t'<<n<<'\n';
      cls = tmp;
      acc = n = 0;
    }
    acc+=var;
    ++n;
  }
  if(n) cout<<cls<<'\t'<<acc/n<<'\t'<<n<<'\n';
  return 0;
}
