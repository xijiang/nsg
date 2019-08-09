#include <iostream>
#include <fstream>
#include <vector>
#include <map>
#include <tuple>
#include <algorithm>

using namespace std;
using PM =tuple<int, int>;
using PED=vector<PM>;
using MID=map<PM, double>;	// store intermediate resultes

bool read_ped(istream&in, PED&ped){
  clog<<"LOG: Reading the pedigree ...\n";
  ped.push_back({0,0});		// the magic dummy
				// hence, row number is ID number id starts from 1.
  for(int pa, ma; in>>pa>>ma; ped.push_back({pa, ma}))
    if(pa>=static_cast<int>(ped.size())
       || ma>=static_cast<int>(ped.size())
       || pa<0 || ma<0){
      cerr<<"ERROR: Invalid pa / ma ID\n";
      return false;
    }
  return true;
}


double Amat(int i, int j, const PED &ped, MID&mid){
  // clog<<i<<' '<<j<<'\n'; //uncomment this to check the stack
  if(i==0 || j==0) return 0;	// so that relationship with un unknown is not stored in mid
  
  if(i>j) swap(i, j);
  
  // Look up if {i,j} was calculated or not
  if(mid.find({i, j})!=mid.end()) return mid[{i, j}];

  const auto &[pa, ma] = ped[j];
  if(i==j)
    mid[{j, j}] = 1 + Amat(pa, ma, ped, mid) / 2.;
  else
    mid[{i, j}] = (Amat(i, pa, ped, mid) + Amat(i, ma, ped, mid)) / 2.;

  return mid[{i, j}];
}

void DnT(const PED&ped, MID&mid){
  ofstream dfile{"D.vec"}, tfile{"T.mat"};
  vector<double> F(ped.size());
  size_t id;

  dfile.precision(12);
  
  // Inbred coefficient first
  F[0] = -1;			// this will avoid the if else things
  for(id=1; id<ped.size(); ++id) F[id] = Amat(id, id, ped, mid) - 1;

  // directly write D and Ti to file
  for(id=1; id<ped.size(); ++id){
    const auto&[pa, ma] = ped[id];

    // D inverse
    dfile << 1./(.5 - .25*(F[pa] + F[ma])) << '\n';

    // T inverse
    auto putT = [](int a, int b, int c, ostream&tfile){
		  if(a) tfile << c << ' ' << a << ' ' << -.5 << '\n';
		  if(b) tfile << c << ' ' << b << ' ' << -.5 << '\n';
		  tfile       << c << ' ' << c << ' ' <<   1 << '\n';
		};
    if(pa<ma) putT(pa, ma, id, tfile);
    else      putT(ma, pa, id, tfile);
  }
}

int main(int argc, char *argv[])
{
  PED ped;			// the pedigree to look up
  if(!read_ped(cin, ped)) return 2;

  map<PM, double> mid;		// store the mid results of Amat
  DnT(ped, mid);

  clog<<"LOG: Number of items of intermediate results: "<<mid.size()<<'\n';
  return 0;
}
