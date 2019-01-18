#include <iostream>
#include <fstream>
#include <vector>

/**
 * This is to convert my G matrix into DMU format, i.e., id1 id2 cor(id1,id2)
 * Usage: ./g2dmu id.lst mat.G
 */

using namespace std;

int main(int argc, char *argv[])
{
  if(argc!=3) {
    cerr<<"Usage: "<<argv[0]<<" id-list G-mat\n";
    return 1;
  }
  
  ifstream fg(argv[2]), fid(argv[1]);
  int      nid;
  vector<string> ids;

  for(string id; fid>>id; ids.push_back(id));
  fg>>nid;
  if(nid!=static_cast<int>(ids.size())){
    cerr<<"ID list size is different from the matrix dimension\n";
    return 2;
  }
  
  fg.ignore();
  double td;
  for(auto i{0}; i<nid; ++i)
    for(auto j{0}; j<=i; ++j){
      fg.read((char*)&td, sizeof(double));
      cout<<ids[i]<<'\t'<<ids[j]<<'\t'<<td<<'\n';
    }
  return 0;
}
