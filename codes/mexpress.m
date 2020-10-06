function [ press, sse, sse_obs ] = mexpress( d, subsets, setting, precomputed )
%MEXPRESS - compute mexpress for given subsets

    % compute the Jacobian and nullspace for each camera model
    if exist('precomputed','var') && isfield(precomputed,'J') && isfield(precomputed,'H')
        J = precomputed.J;
        H = precomputed.H;
    else
        tic; fprintf('> compute J,H ...')
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
        fprintf('%.2fsec\n',toc)
    end

    % compute invQ
    if exist('precomputed','var') && isfield(precomputed,'B') && isfield(precomputed,'invA') ...
             && isfield(precomputed,'invQ') && isfield(precomputed,'invQ12')
        B = precomputed.B;
        invA = precomputed.invA;
        invQ = precomputed.invQ;
        invQ12 = precomputed.invQ12;
    else
        tic; fprintf('> compute invQ ...')
        Q = [J'*J sparse(H); sparse(H)' zeros(7)];      % figure; spy(Q);
        pts_size = 3*length(d.points3D);
        A = Q(1:pts_size,1:pts_size);
        B = Q(1:pts_size,pts_size+1:end);
        D = Q(pts_size+1:end,pts_size+1:end);
        invA = inv3x3(A);

        % inv of camera parameters block
        % invZ = inv(full(D - B' * invA * B));
        [U,S,V] = svd(full(D - B' * invA * B));
        iS = diag(diag(S)./(diag(S).^2 + setting.press_tikhonov_delta));
        invZ = U * iS * V'; 

        invQ12 = invA*B*invZ;
    % %     invQ = full([invA + invQ12*B'*invA	-invQ12;...
    % %                 -invQ12'                 invZ  ]);
        invQ = sparse([invA                    -invQ12(:,1:end-7);...
                      -invQ12(:,1:end-7)'     invZ(1:end-7,1:end-7)]);       
        % + invQ12*B'*invA     ... do not multiply because of the memmory consumption
        invQ12= sparse(invQ12);
        fprintf('%.2fsec\n',toc)
    end
    
    % residuals
    if exist('precomputed','var') && isfield(precomputed,'residuals')
        residuals = precomputed.residuals;
    else
        tic; fprintf('> compute residuals ...')
        m = size(J,1);
        c_imgs = d.images.values;
        residuals = cell2mat(cellfun( @(img) compute_residuals2( ...
            img, d.cameras(img.camera_id), d.points3D, struct('out','XY')), ...
            c_imgs, 'UniformOutput', false ));
        fprintf('%.2fsec\n',toc)
    end
    
    % compute MEXPRESS
    tic; fprintf('> compute mexpress ...')
    sse = zeros(length(subsets),1);
    sse_obs = cell(length(subsets),1);
    if exist('precomputed','var') && isfield(precomputed,'Jres') && isfield(precomputed,'v')
        Jres = precomputed.Jres;
        v = precomputed.v;
    else
        Jres = J' * residuals(:); %
        iQJres = invQ * Jres + [invQ12*(B'*(invA * Jres(1:size(invA,2)))); zeros(size(Jres,1)-size(invA,2),1)];
        v = residuals(:) - (J * iQJres);
    end
    switch setting.press_alg
        case 'MEXPRESS'
%             tic; fprintf('> compute MEXPRESS ...')
%             Jhat = J * invQ(1:size(J,2),1:size(J,2)) * J';
%             
% %             diagJ = cell(length(p3D_ids),1);
%             diagJTik = cell(length(subsets),1);
%             for j = 1:length(subsets)
%                 block_ids = subsets{j}(:);       % Kj ... block of one point3d observations (only p3ds in image "v")
%  
%                 % Tikhonov regularization
%                 [U,S,V] = svd(eye(length(block_ids)) - Jhat(block_ids,block_ids));
%                 iSTik = diag(diag(S)./(diag(S).^2 + setting.press_tikhonov_delta));
%                 diagJTik{j} = U * iSTik * V';
% 
%                 % sum of squres estimate
%                 sse(j) = sum((diagJTik{j} * v(subsets{j}(:))).^2);
%             end
%             
%             for j = 1:length(subsets)
%                 sse(j) = sum((diagJTik{j} * v(subsets{j}(:))).^2);
%             end
%             fprintf('%.2fsec\n',toc)
            
  
        case 'I-MEXPRESS'
            for j = 1:length(subsets)
                block_ids = subsets{j}(:);
                blockJ = J(block_ids,:);
                blockV = v(block_ids);
                blockAhat = blockJ * invQ * blockJ' + ...
                            blockJ * [invQ12*(B'*(invA * blockJ(:,1:size(invA,2))')); zeros(size(Jres,1)-size(invA,2),size(blockJ,1))];

                % iterative approach        
                compute_svd = false;
                change = blockV;
                old_change = zeros(size(blockV)); 
                t = 1;
                while (norm(change) > 1e-8 && norm(old_change - change) > 1e-8 && t < 100) 
                    if norm(old_change) < norm(change)
                        compute_svd = true;
                        break;
                    end
                    old_change = change;
                    change = blockAhat * change;
                    blockV = blockV + change;
                    t = t + 1;
                end
                
                % Tikhonov approach if iterations diverge
                if compute_svd
                    [U,S,V] = svd(eye(length(block_ids)) - blockAhat);
                    iSTik = diag(diag(S)./(diag(S).^2 + setting.press_tikhonov_delta));
                    blockV = U * (iSTik * (V' * blockV));
                end
                
                % sum of squares of predicted errors
                sse_obs{j} = blockV;
                sse(j) = blockV' * blockV;
            end  
    end
    fprintf('%.2fsec\n',toc)

    % press
    press = sum(sse);
    
end
