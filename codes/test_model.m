function [ out ] = test_model( in )
%TEST_model - test the model w.r.t. information criteria
% IN structure "in" with fields:
%   test_alg    one of the information criteria    
%   N           number of datums, each datum corresponds to a physical entity
%   m           m = dim(datum)
%                   e.g., 3 for 3D point in 3D space
%                   e.g., 2 for 2D obseravtion in image
%   r           r = dim(constrains for one datum)
%                   e.g., line in 3D: is 1-dim subspace (d = m - r) with 4 DoF 
%                       => d = 1, m = 3, r = 2, k = 4 
%                   e.g., plane is 3D: is 2-dim (d = m - r) subspace with 3 DoF 
%                       => d = 2, m = 3, r = 1, k = 3 
%   k           dimension of parameters, i.e. 4 for line in 3D and 3
%               for plane in 3D
%   k_M         dimension of vector of parameters of the most complex model M
%   err         the residuals of size r*N between estimated values by given 
%               model and measurements  
%   err_M       the residuals of size r*N between estimated values by the most 
%               complex model and given model and measurements  
%   Sigma2      the true variance(s)/covariance(s) of the residuals
%   Sigma2_M    the true variance(s)/covariance(s) of the residuals
%   err_thresh  the inliers thereshold forrobust IC 
% OUT: 
%   out         result of information criteria for given data
% 
% [1] 'AIC', 'Cp': A. C. Atkinson A - Robust and Diagnostic Information Criterion for Selecting Regresion Models
% [2] 'AICc': K. P. Burnham, D. R. Anderson - Model Selection and Multimodel Inference: A practical information-theoretic approach
% [3] 'CAIC': D. R. Anderson - Comparison of Akaike information criterion and consistent Akaike information criterion for model selection and statistical inference from capture�recapture studies
% [4] 'BIC': J. Chen, Z Chen - Extended Bayesian Information Criteria for Model Selection with Large Model Spaces
% [5] 'HQC': E. J. Hannan - The Determination of the order of an autoregression
% [6] 'MDL','SSD','CAIC': V. L. Orekhov et all - A Full Scale Camera Calibration Technique with Automatic Model Selection � Extension and Validation
% [7] 'BIC': A. Gelman et all - Understanding predictive information criteria for Bazeisian models
% [8] 'SC_tal','SC_hub': S. Saleh et all - A Robust Version of Schwarz Information Criterion Based on LTS
% [9] 'G_AIC','G_MDL': K. Kanatani et all - Uncertainty Modeling and Model Selection for Geometric Inference 
% [10] 'RTIC_tal', 'RTIC_hub': P. Bouthemy at all - Robust Model Selection in 2D Parametric Motion Estimation


    % the dimension of solution subspace
    N = in.N;
    m = in.m;
    r = in.r;
    d = m - r;
    k = in.k;
    k_M = in.k_M;
    
    % sigma
    if isfield(in,'Sigma2')
        sigma2 = in.Sigma2;
    else
        if isfield(in,'err_M') && ~isempty(err_M)  
            sigma2 = (in.err_M'*in.err_M) / (r*N - k_M); % unbiased estimator of sigma for the most complex model
        else	
            sigma2 = (in.err'*in.err) / (r*N - k);     % unbiased estimator of sigma for given model
        end
    end
    
    
    % threshold from sigma if not known
    if isfield(in,'err_thresh')
        err_thresh = in.err_thresh;
    else
        err_thresh = 3 * sqrt(sigma2);  % 99.7 proc values
    end
    
    
    % compute R
    R = in.err' * inv(sigma2) * in.err;
    if isfield(in,'err_M') && isfield(in,'Sigma_M')
        R_M = in.err_M' * in.Sigma_M * in.err_M;
    else
        R_M = R;
    end
    
    % compute T
    if max(size(sigma2)) > 1
        T = - 0.5 * (log(det(sigma2)) + m*N * log(2*pi));
    else
        T = - 0.5 * m * N *  (log(sigma2) + log(2*pi));
    end
    
    
    % compute L
    L = T - R;

    

    %% IC
    out = NaN;
    switch in.test_alg
        case 'ACS'  % accuracy is evaluated in different script
            out = NaN;
        case 'REPROJ_ERR'
            out = sqrt(R);
        case 'LIC'
            out = struct('R',R,'R_M',R_M,'T',T,'N',N,'k',k,'k_M',k_M,...
                'sigma2', R / (r*N - k));
        case 'AIC'  % [Akaike, 1973]
            out = -2*L + 2*k;
        case 'AICc' % second order estimate of information lost
            out = -2*L + 2*k + (2*k*k + 2*k)/(r*N - k - 1);
        case 'CAIC' % [Bozdogan, 1987]
            out = -2*L + k*(log(r*N)+1);
        case 'Cp'   % for fixed N and sigma [Mallows, 1973]
            if isfield(in,'k_M') && isfield(in,'err_M') && isfield(in,'Sigma_M') 
                out = (r*N-k_M)*R/R_M - r*N + 2*k;
            end
        case 'BIC'  % [Schwarz, 1978]
            out = -2*L + k*log(r*N); 
        case 'HQC'
            out = -2*L + 2*k*log(log(r*N));
        case 'MDL'  % [Rissanen 1978]
            out = -L + 0.5*k*log(r*N);
        case 'SSD'  % [Rissanen 1978]
            out = -2*L + k*log((r*N+2)/24) + 2*log(k+1);
        case 'DIC'      % https://en.wikipedia.org/wiki/Deviance_information_criterion
            out = NaN;
        case 'BPIC'     % Ando, Tomohiro (2011). "Predictive Bayesian Model Selection"
            out = NaN;
        case 'G_AIC'    % [Kanatani, 2004]    
            eps2 = R / (r*N - k);
%             if max(size(sigma2)) > 1
%                 L = - (R/(2*eps2) + (m*N*log(2*pi*eps2))/2 + log(det(sigma2))/2);
%             else
%                 L = - (R/(2*eps2) + (m*N*log(2*pi*eps2))/2 + m*N*log(sigma2)/2);
%             end
            %J = 
            out = L + 2*(N*d+k)*eps2;
        case 'G_MDL'    % [Kanatani, 2004]       
            eps2 = R / (r*N - k);
%             if max(size(sigma2)) > 1
%                 L = - (R/(2*eps2) + (m*N*log(2*pi*eps2))/2 + log(det(sigma2))/2);
%             else
%                 L = - (R/(2*eps2) + (m*N*log(2*pi*eps2))/2 + m*N*log(sigma2)/2);
%             end
            out = -(L - (N*d+k)*eps2*log(eps2));         
        case 'SC_tal'     % the bias compensation is wrong in the paper [8]
            w_err = sqrt(sum(reshape(in.err .* (sigma2 * in.err), 2, length(in.err)/2).^2));
            out = -2*T + sum(talwar_penalty(w_err, err_thresh)) + k*log(N)/N;
        case 'SC_hub'     % the bias compensation is wrong in the paper [8]
            w_err = sqrt(sum(reshape(in.err .* (sigma2 * in.err), 2, length(in.err)/2).^2));
            out = -2*T + sum(talwar_penalty(w_err, err_thresh)) + k*log(N)/N;
        case 'RAIC_tal'
            w_err = sqrt(sum(reshape(in.err .* (sigma2 * in.err), 2, length(in.err)/2).^2));
            out = -2*T + sum(talwar_penalty(w_err, err_thresh)) + k;
        case 'RAIC_hub'
            w_err = sqrt(sum(reshape(in.err .* (sigma2 * in.err), 2, length(in.err)/2).^2));
            out = -2*T + sum(huber_penalty(w_err, err_thresh)) + k;
        case 'RBIC_tal'
            w_err = sqrt(sum(reshape(in.err .* (sigma2 * in.err), 2, length(in.err)/2).^2));
            out = -2*T + sum(talwar_penalty(w_err, err_thresh)) + k*log(N);
        case 'RBIC_hub'
            w_err = sqrt(sum(reshape(in.err .* (sigma2 * in.err), 2, length(in.err)/2).^2));
            out = -2*T + sum(huber_penalty(w_err, err_thresh)) + k*log(N);
        case 'RTIC_tal'     % [Bouthemy, 2019]
            w_err = sqrt(sum(reshape(in.err .* (sigma2 * in.err), 2, length(in.err)/2).^2));
            inl = w_err < err_thresh;
            out = -2*T + 2*sum(talwar_penalty(w_err, err_thresh)) + (2*k*sum(w_err(inl)))/sum(inl);
        case 'RTIC_hub'     % [Bouthemy, 2019]
            w_err = sqrt(sum(reshape(in.err .* (sigma2 * in.err), 2, length(in.err)/2).^2));
            inl = w_err < err_thresh;
            out = -2*T + 2*sum(huber_penalty(w_err, err_thresh)) + (2*k*(sum(w_err(inl))+sum(~inl)*err_thresh^2))/sum(inl);
        case 'FRIC1'
            w_err = sqrt(sum(reshape(in.err .* (sigma2 * in.err), 2, length(in.err)/2).^2));
            inl = w_err < err_thresh;
            sigma2 = sum(w_err.^2) / (r*sum(inl) - k_M);      
%             if isfield(in,'err_M') && isfield(in,'Sigma_M')
%                 w_err_M = sqrt(sum(reshape(in.err_M .* in.Sigma_M * in.err_M, 2, length(in.err)/2).^2));
%                 inl_M = w_err_M < err_thresh;
%                 
%             end
            out = (sum(w_err(inl).^2)/sigma2) - sum(inl) + k_M + 2*k;
        case 'FRIC2'
%             err = sqrt(err2);
%             inl = err < err_thresh;
%             if length(err2_M) ~= length(inl)    % the largest model has different number of observations, in the case of 3D reconstruction
%                 inl = sqrt(err2_M) < err_thresh;
%             end
%             M_sigma2 = sum(err2_M(inl)) / (sum(inl) - k_M); 
%             inl = err < err_thresh;

            w_err = sqrt(sum(reshape(in.err .* (sigma2 * in.err), 2, length(in.err)/2).^2));
            inl = w_err < err_thresh;
            sigma2 = sum(w_err.^2) / (r*sum(inl) - k_M);      
            out = (sum(w_err(inl).^2)/sigma2) - sum(inl) + k_M + 2*k*log(sum(inl));
            
        otherwise
            error('Unknown camera model test.');
    end  
end



