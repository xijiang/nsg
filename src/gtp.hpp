/**
 * this small struct is to avoid the frame limitation problem.
 * when nlc x nid is large, 
 * a declarition like gt[nid][nlc] usually leads to a segmentation error
 */

#ifndef __gt_class_
#define __gt_class_

class GTP{
public:
  int      nid, nlc;
  double **g;
    
  GTP(int _nid, int _nlc):nid(_nid), nlc(_nlc){
    g = new double*[nid];
    for(auto i=0; i<nid; ++i) g[i] = new double[nlc];
  }
    
  ~GTP(){
    for(auto i=0; i<nid; ++i) delete[] g[i];
    delete[] g;
  }
};

#endif
