#include <iostream>
#include <map>

using namespace std;
using MSS=map<string, string>;

int main(int argc, char *argv[])
{
  MSS month{{"Jan", "01"},
	    {"Feb", "02"},
	    {"Mar", "03"},
	    {"Apr", "04"},
	    {"May", "05"},
	    {"Jun", "06"},
	    {"Jul", "07"},
	    {"Aug", "08"},
	    {"Sep", "09"},
	    {"Oct", "10"},
	    {"Nov", "11"},
	    {"Dec", "12"}};
  MSS order;
  string line;

  while(cin>>line)
    order[line.substr(12,2)+month[line.substr(9,3)]+line.substr(7,2)] = line;

  cout<<order.rbegin()->second<<endl;
  return 0;
}
