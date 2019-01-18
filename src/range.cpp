#include <iostream>

using namespace std;
/**
 * to find the min and max of a matrix
 */
int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  
  double min, max, td;
  
  cin>>td;
  min = max = td;
  
  while(cin>>td){
    if(min>td) min=td;
    if(max<td) max=td;
  }

  cout<<min<<'\t'<<max<<'\n';
  return 0;
}
