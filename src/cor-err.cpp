#include <iostream>
#include <cmath>

using namespace std;

int main(int argc, char *argv[])
{
  double sx{0}, sy{0}, x2{0}, y2{0}, xy{0}, n{0}, er{0};
  for(string s1, g1, s2, g2; cin>>s1>>g1>>s2>>g2;){
    if(s1!=s2) cerr<<"SN not match <<s1<<' '<<s2<<'\n'";
    if(g1.length()!=g2.length()) cerr<<"N_ID not match\n";
    n+=g1.length();
    for(size_t i{0}; i<g1.length(); ++i){
      if(g1[i]!=g2[i]) ++er;
      double x=g1[i]-'0';
      double y=g2[i]-'0';
      sx+=x;
      sy+=y;
      x2+=x*x;
      y2+=y*y;
      xy+=x*y;
    }
  }
  cout.precision(12);
  cout<<"    Genotype error rate: "<<er/n<<'\n';
  double cor = (n*xy-sx*sy) / sqrt((n*x2-sx*sx)*(n*y2-sy*sy));
  cout<<"Correlation coefficient: "<<cor<<'\n';
  return 0;
}
