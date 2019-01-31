#include <iostream>

using namespace std;

int main(int argc, char *argv[])
{
  int nid, nlc, dum;
  cin>>nid>>nlc;

  cout<<nid<<' '<<nlc<<'\n';
  
  for(auto i{0}; i<nlc; ++i){
    cin>>dum;
    cout<<nid<<'\n';
  }

  string line;
  while(cin>>line) cout<<line<<'\n';
  
  return 0;
}
