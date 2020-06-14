#include "Eigen/Dense"
#include "mex.h"

#ifndef NDEBUG 
#undef eigen_assert
#define eigen_assert(x) \
if (!x) { mexErrMsgTxt(EIGEN_MAKESTRING(x)); }
#endif

#include "f10e_solver.h"

using namespace Eigen;

void mexFunction(int nlhs,mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
  if ((nrhs < 2) || (nrhs > 3))
    mexErrMsgTxt("F10e(X, U, [pivtol]): Please specify two 10x2 coefficient matrices as input with pivtol as an optional third parameter");

  double *x = mxGetPr(prhs[0]);
  double *u = mxGetPr(prhs[1]);

  double pivtol = 1e-16;
  if (nrhs == 3)
    pivtol = *(mxGetPr(prhs[2]));

  if ((mxGetM(prhs[0]) != 10) || (mxGetN(prhs[0]) != 2))
    mexErrMsgTxt("Coefficient matrix sizes must be [10, 2]");
 
  if ((mxGetM(prhs[1]) != 10) || (mxGetN(prhs[1]) != 2))
    mexErrMsgTxt("Coefficient matrix sizes must be [10, 2]");

  Matrix<double, 9, 10> Fs;
  Matrix<double, 2, 10> Ls;

  int nsols = f10e_solver(Map<Matrix<double, 10, 2> >(x, 5, 2), Map<Matrix<double, 10, 2> >(u, 5, 2), Fs, Ls, pivtol);

  // Fs
  plhs[0] = mxCreateDoubleMatrix(9, nsols, mxREAL);
  Map<MatrixXd> Fs_mat(mxGetPr(plhs[0]), 9, nsols);
  Fs_mat = Fs.block(0, 0, 9, nsols);

  // lambdas
  plhs[1] = mxCreateDoubleMatrix(2, nsols, mxREAL);
  Map<MatrixXd> Ls_mat(mxGetPr(plhs[1]), 2, nsols);
  Ls_mat = Ls.block(0, 0, 2, nsols);
}