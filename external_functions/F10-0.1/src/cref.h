/* colEchelonForm: Computes column echelon form of a matrix

Copyright (c) 2015, Jan Heller, <hellej1@cmp.felk.cvut.cz>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the names of the Czech Technical University and Microsoft nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDERS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifndef _CREF_H_
#define _CREF_H_
  
#include <cmath>
#include <limits>
#include <Eigen/Dense>

template <typename Derived> 
inline void colEchelonForm(Eigen::MatrixBase<Derived> &M, double pivtol = 1e-12) 
{
  typedef typename Derived::Scalar Scalar;

  int n = M.rows();
  int m = M.cols();
  int i = 0, j = 0, k = 0;
  int col = 0;
  Scalar p, tp;

  while((i < m) && (j < n))
    {
      p = std::numeric_limits<Scalar>::min();
      col = i;

      for (k = i; k < m; k++)
        {
          tp = std::abs(M(j, k));
          if (tp > p)
	    {
	      p = tp;
	      col = k;
	    }
        }

      if (p < Scalar(pivtol))
        {
          M.block(j, i, 1, m - i).setZero();
          j++;
        }
      else
        {
          if (col != i)
  	    M.block(j, i, n - j, 1).swap(M.block(j, col, n - j, 1));

          M.block(j + 1, i, n - j - 1, 1) /= M(j, i);
          M(j, i) = 1.0;

          for (k = 0; k < m; k++)
	    {
	      if (k == i)
	        continue;

	      M.block(j, k, n - j, 1) -= M(j, k) * M.block(j, i, n - j, 1);
	    }
          
          i++;
          j++;
        }
    }
}

#endif
