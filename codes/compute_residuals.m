function [ res, err, err_orig, cov_xys ] = compute_residuals( img, cam, points3D )
    reconst_filter = img.point3D_ids ~= -1;
    u_obs = img.xys(reconst_filter,:)';
    pt3D_ids = img.point3D_ids(reconst_filter);
    if isfield(img, 'xys_cov')
        cov_xys = img.xys_cov(reconst_filter,:)';
    end
    if isempty(pt3D_ids)
        res = [];
        warning('Residuals cannot be computed because the image hase no reprojections.');
        return;
    end
    [~,~,IB] = intersect(cell2mat(points3D.keys),pt3D_ids);
    if size(IB,1) ~= size(pt3D_ids,1)
        warning('The image %d contains point in 3D id which des not exist.',img.image_id);
    end
    
    pts = arrayfun(@(pt_id) points3D(pt_id).xyz, pt3D_ids(IB), 'UniformOutput', false);
    if ( size(pts,1) ~= 1 )
        pts = pts';
    end
    if exist('cov_xys', 'var')
        cov_xys = cov_xys(:,IB);
    end
    X = cell2mat(pts);
    u_proj = proj( cam, img, X );
    
    err_orig = u_obs(:,IB) - u_proj;
    err = err_orig;
    res = sqrt(sum(err_orig.^2));
    
    % inliers clasification 
    if isfield(img,'xys_std')
        % with normalization
        E = img.xys_std(IB,:)';      % covariances
        ferr = find(sum(E) ~= 0);
        err(:,ferr) = cell2mat(arrayfun(@(j) inv(reshape(E(:,j),2,2)) * err(:,j), ferr, 'UniformOutput', false)); 
        res = sqrt(sum(err.^2));
    end

    
%     % plot 
%     figure()
%     plot(u_obs(2,IB),u_obs(1,IB),'go'); hold on;
%     dir_err = obs_dir .* err;
%     for i = 1:size(IB,1)
%         plot([u_obs(2,IB(i)) u_obs(2,IB(i))+100*err(2,i)], ...
%             [u_obs(1,IB(i)) u_obs(1,IB(i))+100*err(2,i)],'r-')
%     end
end

function pp = get_principal_point(cam)
    cp = cam.params;
    pp = cp(2:3);
    switch cam.model  
        case 'PINHOLE'              % fx, fy, cx, cy
            pp =  cp(3:4);
        case 'OPENCV'               % fx, fy, cx, cy, k1, k2, p1, p2
            pp =  cp(3:4);
        case 'OPENCV_FISHEYE'       % fx, fy, cx, cy, k1, k2, k3, k4   
            pp =  cp(3:4);
        case 'FULL_OPENCV'          % fx, fy, cx, cy, k1, k2, p1, p2, k3, k4, k5, k6
            pp =  cp(3:4);
    end
end