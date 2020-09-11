function [ out ] = prepare_mexpress( d, residuals, setting )
%PREPARE_MEXPRESS - precompute values required for mexpress
    
    % compute the Jacobian and nullspace for each camera model
    c_imgs = d.images.values;
    if ~isfield(c_imgs{1},'xys_cov')
        if isfield(setting,'sigma')
            d = add_obs_variance(d, setting.sigma^2);
        else
            d = add_obs_variance(d, 1);
        end
    end
    opt = struct('alg','JACOBIAN_ESTIMATOR','in_cov','UNIT','run_opt',0,'run_opt_radial',0,'return_nullspace',1);
    [~, ~, strJ,H] = usfm_mex(opt, d.cameras.values, d.images.values, d.points3D.values);
    J = sparse(strJ.rows, strJ.columns, strJ.values, strJ.num_rows, strJ.num_columns); 

    % compute invQ
    Q = [J'*J sparse(H); sparse(H)' zeros(7)];      % figure; spy(Q);
    pts_size = 3*length(d.points3D);
    A = Q(1:pts_size,1:pts_size);
    B = Q(1:pts_size,pts_size+1:end);
    D = Q(pts_size+1:end,pts_size+1:end);
    invA = inv3x3(A);
    
    % inv of camera parameters block
    [U,S,V] = svd(full(D - B' * invA * B));
    iS = diag(diag(S)./(diag(S).^2 + setting.press_tikhonov_delta));
    invZ = U * iS * V'; 
    invQ12 = invA*B*invZ;
    invQ = sparse([invA                    -invQ12(:,1:end-7);...
                  -invQ12(:,1:end-7)'     invZ(1:end-7,1:end-7)]);       
    invQ12= sparse(invQ12);
    
    
    Jres = J' * residuals(:); %
    iQJres = invQ * Jres + [invQ12*(B'*(invA * Jres(1:size(invA,2)))); zeros(size(Jres,1)-size(invA,2),1)];
    v = residuals(:) - (J * iQJres);
    
    % setup the output values
    out.v = v;
    out.J = J;
    out.H = H;
    out.Jres = Jres;
    out.invQ = invQ;
    out.invQ12 = invQ12;
    out.B = B;
    out.invA = invA;
    
end

