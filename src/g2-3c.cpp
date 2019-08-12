#include <iostream>
#include <fstream>
#include <vector>

/**
 * This will convert my G matrix into 3 columns
 * An ID file contains a column of ID names is needed for this conversion
 */
using namespace std;

int main(int argc, char *argv[])
{
  ios_base::sync_with_stdio(false);
  if(argc!=2){
    cerr<<"Usage: cat some.G | "<<argv[0]<<" id-list > target.3c\n";
    return 0;
  }
  
  int nid, nlc;
  cin>>nid>>nlc;
  
  vector<string> ID;
  {
    ifstream fin(argv[1]);
    for(string id; fin>>id; ID.push_back(id));

    if(static_cast<size_t>(nid)!=ID.size()){
      cerr<<"Dimension not match. \n";
      return 2;
    }
  }

  cin.ignore();
  double td;
  cout.precision(12);
  for(auto i=0; i<nid; ++i)
    for(auto j=0; j<=i; ++j){
      cin.read((char*)&td, sizeof(double));
      cout<<ID[i]<<'\t'<<ID[j]<<'\t'<<td<<'\n';
    }
  return 0;
}
