function [res, J] = accuracy_of_pair( d, sigma, setting )
    % setting 
    pref = struct();
    pref.alg = 'JACOBIAN_ESTIMATOR';
    pref.in_cov = 'UNIT';
    pref.run_opt = 0;
    pref.run_opt_radial = 0;
    pref.return_nullspace = 0;

    % compute Jacobian & scene nullspace 
    [~, ~, strJ] = usfm_mex(pref, d.cameras.values, d.images.values, d.points3D.values);
    J = sparse(strJ.rows, strJ.columns, strJ.values, strJ.num_rows, strJ.num_columns);  
    
    % observations weights
    S_u = speye(size(J,1));
    c_imgs = d.images.values;
    if ~isfield(c_imgs{1},'xys_cov')
        if nargin > 1 && ~isempty(sigma)
            S_u = (1 / sigma^2) * speye(size(J,1));
        end
    else
        S_u = sparse(size(J,1));
        t = 1;
        for i = 1:length(c_imgs)
            for j = 1:size(c_imgs{i}.xys_cov,1)
                C_i = reshape(c_imgs{i}.xys_cov(j,:),2,2);
                if sum(sum(abs(C_i))) == 0
                    S_u(t:t+1, t:t+1) = eye(2);
                else
                    S_u(t:t+1, t:t+1) = sparse(inv(C_i));
                end
                t = t+2;
            end
        end
    end
    
    % reorder J to have extrinsic parameters of cameras first
    npts = size(d.points3D,1);
    nimgs = size(d.images,1);
    J = [J(:,3*npts+1:3*npts+6*nimgs) J(:,1:3*npts)];
    
%     % scale Jacobian
%     S = sparse(1:size(J,2),1:size(J,2), ...
%         arrayfun(@(jcol) nnz(J(:,jcol)), 1:size(J,2)) ./ sum(J),...
%         size(J,2),size(J,2));
%     J = J * S;
    
    % information matrix
    A = J' * S_u * J;
    
    % split A to common parameters and the rest
    % it is assumed: 6 parameters for extrinsic calibration of the camera
    ncommon = 6*nimgs;   
    if exist('setting','var') && isfield(setting,'acs_params')
        if strcmp(setting.acs_params,'CAMS&PTS')
            ncommon = 6*nimgs + 3*npts;
        elseif strcmp(setting.acs_params,'CAMS')
            ncommon = 6*nimgs;
        end 
    end
    A11 = A(1:ncommon, 1:ncommon);
    A12 = A(1:ncommon, ncommon+1:end);
    A21 = A(ncommon+1:end, 1:ncommon);
    A22 = A(ncommon+1:end, ncommon+1:end);
    
    % create matrix which can be compared
    %S11 = S(1:size(A11,1),1:size(A11,1));
    iA22_A21 = A22 \ A21;
    A_trace = (diag(A11)' - sum(A12' .* iA22_A21));  %(S11.^2) .* 
    A_add = A12 * iA22_A21;
    A_compare = (A11 - A_add);    % S11 * ... * S11
    
    
    % return results 
    res = struct();
    res.AC_trace = sum(A_trace);
    res.AC_lambda_max = eigs(A_compare,1);
    res.AC_lambda_min = eigs(A_compare,8,'sm');
    
    res.A11_trace = sum(diag(A11));
    res.Aadd_trace = sum(diag(A_add));
    res.AC_eig = sort(real(eig(full(A_compare))),'descend');
    res.A11_eig = sort(real(eig(full(A11))),'descend');
    res.Aadd_eig = sort(real(eig(full(A_add))),'descend');
    
    
%     % power method to get largest eigenvalue
%     if nargout > 3
%         x = (1/size(iA22_A21,2)) * ones(size(iA22_A21,2),1);
%         e = 0;
%         for i = 1:10
%             new_x = (A12 * (iA22_A21 * x));
%             new_e = (x' * new_x) / (x' * x);
%             if abs(new_e - e)/abs(new_e) < 1e-4
%                 break;
%             end
%             e = new_e;
%             x = new_x / norm(new_x);
%         end
%         res.max_eig = e;
%     end
end

