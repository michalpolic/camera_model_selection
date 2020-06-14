#include <cmath>
#include "mex.hpp"
#include "mexAdapter.hpp"

using matlab::mex::ArgumentList;
using namespace matlab::data;
using namespace matlab::engine;

class MexFunction : public matlab::mex::Function {
    // Pointer to MATLAB engine to call fprintf
    std::shared_ptr<matlab::engine::MATLABEngine> matlabPtr = getEngine();

    // Factory to create MATLAB data arrays
    ArrayFactory factory;
    
    // Create an output stream
    std::ostringstream stream;
    
public:
    void operator()(ArgumentList outputs, ArgumentList inputs) {
        // input arrays
        const int N = (int) inputs[0][0];
        const double ransac_threshold = inputs[1][0];
        double sqrt_delta = inputs[2][0];
        double sqrt_epsilon = inputs[3][0];
        double decision_threshold_sqrt = inputs[4][0];
        
        const TypedArray<double> x_i = inputs[5];
        const TypedArray<double> u_i = inputs[6];
        const TypedArray<double> F = std::move(inputs[7]);
        const double l1 = inputs[8][0];
        const double l2 = inputs[9][0];
        const TypedArray<double> K1 = std::move(inputs[10]);
        const TypedArray<double> K2 = std::move(inputs[11]);
//         stream << "Input params: N = " << N << ", thr = " << ransac_threshold << ", d = " << sqrt_delta
//                 << ", e: " << sqrt_epsilon << ", dec = " << decision_threshold_sqrt << std::endl;
//         displayOnMATLAB(stream);
        

        //output arrays
        TypedArray<double> errs = factory.createArray<double>({ N, 1 });
        
        // process 
		double model_rejected = 0;
        double lambdaj, lambdaj_1 = 1.0;
        int numInliers = 0;
        
        for (int i = 0; i < N; ++i) {
            // error of one point
            errs[i] = modelErrors(x_i[0][i], x_i[1][i], u_i[0][i], u_i[1][i], F, l1, l2, K1, K2);
//             stream << "errs[i] = " << errs[i] << std::endl;
//             displayOnMATLAB(stream);
        
      	 	// update inliers
            if (errs[i] < ransac_threshold){
                numInliers = numInliers + 1;
                lambdaj = lambdaj_1 * (sqrt_delta / sqrt_epsilon);
            }else {
                lambdaj = lambdaj_1 * ((1 - sqrt_delta) / (1 - sqrt_epsilon));
            }

            if (lambdaj > decision_threshold_sqrt){
                model_rejected = 1;
                for (int j = i+1; j < N; ++j) {
                    errs[j] = INFINITY;
                }
                break;
            }else{
            	lambdaj_1 = lambdaj;
            }
        }

        // output
        outputs[0] = factory.createScalar(model_rejected);
        outputs[1] = std::move(errs);
        outputs[2] = factory.createScalar(numInliers);
    }
    
    // computes residual
    inline double modelErrors(const double x_i1, const double x_i2, const double u_i1, const double u_i2,
            const TypedArray<double> F, const double l1, const double l2, const TypedArray<double> K1, const TypedArray<double> K2){
        
        // x_i to 1. camera coordinate system
        const double x_c1_t = x_i1 / K1[0][0] - K1[0][2] / K1[0][0];
        const double x_c2_t = x_i2 / K1[1][1] - K1[1][2] / K1[1][1];
        const double Rc = 1 / (1 + l1 * (x_c1_t * x_c1_t + x_c2_t * x_c2_t));
        const double x_c1 = x_c1_t * Rc;
        const double x_c2 = x_c2_t * Rc;
//         stream << "x_c1 = " << x_c1 << ", x_c2 = " << x_c2 << std::endl;
//         displayOnMATLAB(stream);
        
        // u_i to 2. camera coordinate system
        const double u_c1_t = u_i1 / K2[0][0] - K2[0][2] / K2[0][0];
        const double u_c2_t = u_i2 / K2[1][1] - K2[1][2] / K2[1][1];
        const double Ru = 1 / (1 + l2 * (u_c1_t * u_c1_t + u_c2_t * u_c2_t));
        const double u_c1 = u_c1_t * Ru;
        const double u_c2 = u_c2_t * Ru;
//         stream << "u_c1 = " << u_c1 << ", u_c2 = " << u_c2 << std::endl;
//         displayOnMATLAB(stream);
        
        // u_c to 1. camera coordinate system as a point on the epipolar line closest to x_c
        const double cam1_ls1 = F[0][0]*u_c1 + F[0][1]*u_c2 + F[0][2];
        const double cam1_ls2 = F[1][0]*u_c1 + F[1][1]*u_c2 + F[1][2];
        const double cam1_ls3 = F[2][0]*u_c1 + F[2][1]*u_c2 + F[2][2];
        
        const double cam1_ay = cam1_ls1 * x_c2;
        const double cam1_bx = cam1_ls2 * x_c1;
        const double cam1_ac = cam1_ls1 * cam1_ls3;
        const double cam1_bc = cam1_ls2 * cam1_ls3;

        const double cam1_dd = cam1_ls1*cam1_ls1 + cam1_ls2*cam1_ls2;
        const double ut_c1 = (cam1_ls2 * (cam1_bx - cam1_ay) - cam1_ac) / cam1_dd; 
        const double ut_c2 = (cam1_ls1 * (cam1_ay - cam1_bx) - cam1_bc) / cam1_dd;
//         stream << "ut_c1 = " << ut_c1 << ", ut_c2 = " << ut_c2 << std::endl;
//         displayOnMATLAB(stream);
        
        
        // x_c to 2. camera coordinate system as a point on the epipolar line closest to u_c
        const double cam2_ls1 = F[0][0]*x_c1 + F[1][0]*x_c2 + F[2][0];
        const double cam2_ls2 = F[0][1]*x_c1 + F[1][1]*x_c2 + F[2][1];
        const double cam2_ls3 = F[0][2]*x_c1 + F[1][2]*x_c2 + F[2][2];
        
        const double cam2_ay = cam2_ls1 * u_c2;
        const double cam2_bx = cam2_ls2 * u_c1;
        const double cam2_ac = cam2_ls1 * cam2_ls3;
        const double cam2_bc = cam2_ls2 * cam2_ls3;

        const double cam2_dd = cam2_ls1*cam2_ls1 + cam2_ls2*cam2_ls2;
        const double xt_c1 = (cam2_ls2 * (cam2_bx - cam2_ay) - cam2_ac) / cam2_dd; 
        const double xt_c2 = (cam2_ls1 * (cam2_ay - cam2_bx) - cam2_bc) / cam2_dd;
//         stream << "xt_c1 = " << xt_c1 << ", xt_c2 = " << xt_c2 << std::endl;
//         displayOnMATLAB(stream);
        
        
        // ut_c to 1. image coordinate system   
        const double cam1_Xd = 0.5 * ut_c1 / (l1*ut_c2*ut_c2 + l1*ut_c1*ut_c1) * (1 - sqrt(1 - 4*l1*ut_c2*ut_c2 - 4*l1*ut_c1*ut_c1));
        const double cam1_Yd = 0.5 / (l1*ut_c2*ut_c2 + l1*ut_c1*ut_c1) * (1 - sqrt(1 - 4*l1*ut_c2*ut_c2 - 4*l1*ut_c1*ut_c1)) * ut_c2;
        double ut_i1, ut_i2;
        if (std::isnan(cam1_Xd)){
            ut_i1 = K1[0][0] * ut_c1 + K1[0][2];
        }else{
            ut_i1 = K1[0][0] * cam1_Xd + K1[0][2];
        }  
        if (std::isnan(cam1_Yd)){
            ut_i2 = K1[1][1] * ut_c2 + K1[1][2];
        }else{
            ut_i2 = K1[1][1] * cam1_Yd + K1[1][2];
        }   
//         stream << "ut_i1 = " << ut_i1 << ", ut_i2 = " << ut_i2 << std::endl;
//         displayOnMATLAB(stream);
        
        // xt_c to 2. image coordinate system
        const double cam2_Xd = 0.5 * xt_c1 / (l2*xt_c2*xt_c2 + l2*xt_c1*xt_c1) * (1 - sqrt(1 - 4*l2*xt_c2*xt_c2 - 4*l2*xt_c1*xt_c1));
        const double cam2_Yd = 0.5 / (l2*xt_c2*xt_c2 + l2*xt_c1*xt_c1) * (1 - sqrt(1 - 4*l2*xt_c2*xt_c2 - 4*l2*xt_c1*xt_c1)) * xt_c2;
        double xt_i1, xt_i2;
        if (std::isnan(cam2_Xd)){
            xt_i1 = K2[0][0] * xt_c1 + K2[0][2];
        }else{
            xt_i1 = K2[0][0] * cam2_Xd + K2[0][2];
        }        
        if (std::isnan(cam2_Yd)){
            xt_i2 = K2[1][1] * xt_c2 + K2[1][2];
        }else{
            xt_i2 = K2[1][1] * cam2_Yd + K2[1][2];
        }  
//         stream << "xt_i1 = " << xt_i1 << ", xt_i2 = " << xt_i2 << std::endl;
//         displayOnMATLAB(stream);
        
        
        return 0.5 * ((x_i1 - ut_i1) * (x_i1 - ut_i1) + (x_i2 - ut_i2) * (x_i2 - ut_i2) + 
                      (u_i1 - xt_i1) * (u_i1 - xt_i1) + (u_i2 - xt_i2) * (u_i2 - xt_i2));
    }

    
    inline void displayOnMATLAB(std::ostringstream& stream) {
        // Pass stream content to MATLAB fprintf function
        matlabPtr->feval(u"fprintf", 0,
            std::vector<Array>({ factory.createScalar(stream.str()) }));
        // Clear stream buffer
        stream.str("");
    }
};