#include <iostream>
#include <vector>

using namespace std;

int main(int argc, char *argv[])
{
  vector<double> rt;
  double x;
  string tmp;
  while(cin>>tmp){
    cin>>tmp>>tmp>>tmp>>tmp>>x;
    rt.push_back(x);
    cin>>tmp>>tmp>>x;
    rt.push_back(x);
  }
  int seg=static_cast<int>(rt.size()/3);
  for(auto i=0; i<seg; i+=2){
    cout<<rt[i      ]<<'\t'<<rt[i+1      ]<<'\t';
    cout<<rt[i+seg  ]<<'\t'<<rt[i+1+seg  ]<<'\t';
    cout<<rt[i+seg*2]<<'\t'<<rt[i+1+seg*2]<<'\n';
  }
  return 0;
}
