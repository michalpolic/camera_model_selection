function d = normalize_dataset(d)
%NORMALIZE_DATASET - normalize the colamp dataset coordinate system

% NOTE: we assume different number of reconstructed points in 3D but which
% may differ on the boundary of the reconstruction but the same number of
% cameras which are relatively accurately determined (after BA)


    % 1) extract all the camera centers 
    c_imgs = d.images.values; 
    C = cell2mat(cellfun(@(img) -img.R' * img.t, c_imgs, 'UniformOutput', false));
    
    % 2) normalize mean and std from center of coordiante system
    shift = mean(C,2);
    C = C - shift;
    dist = sqrt(sum(C.*C));
    if size(C,2) == 2
        scale = 1/mean(dist);
    else
        scale = (1/std(dist));
    end
    
    % 3) apply the transformation to points in 3D and camera centers 
    for i = 1:size(c_imgs,2)
        img = c_imgs{i};
        newC = scale * ((-img.R' * img.t) - shift);
        img.t = - img.R * newC;
        d.images(img.image_id) = img;
    end
    c_pts = d.points3D.values;
    for i = 1:size(c_pts,2)
       pt = c_pts{i};
       pt.xyz = scale * (pt.xyz - shift);
       d.points3D(pt.point3D_id) = pt;
    end
    
    % 4) rotate the scene to have the main axis of cov(camera centers)
    % alighned with x,y,z
    c_imgs = d.images.values; 
    C = cell2mat(cellfun(@(img) -img.R' * img.t, c_imgs, 'UniformOutput', false));
    [R,~] = eig(cov(C'));
    R = sign(det(R)) * R';
    
    % 5) apply R
    for i = 1:size(c_imgs,2)
        img = c_imgs{i};
        img.R = img.R * R';
        img.q = r2q(img.R);
        %img.t = img.t;
        d.images(img.image_id) = img;
    end
    c_pts = d.points3D.values;
    for i = 1:size(c_pts,2)
       pt = c_pts{i};
       pt.xyz = R * pt.xyz;
       d.points3D(pt.point3D_id) = pt;
    end
    
    % 6) normalize the observations and focal length
    % 6.1) cameras 
    cams2 = containers.Map('KeyType','int64','ValueType','any');
    cams_change = containers.Map('KeyType','int64','ValueType','any');
    c_cams = d.cameras.values;
    for i = 1:length(c_cams)
        cam = c_cams{i};
        cc = struct('approx_if',1/cam.width,'approx_pp',[cam.width/2; cam.height/2]);
        switch cam.model
            case 'OPENCV'               % fx, fy, cx, cy, k1, k2, p1, p2  
                cam.params(1:2) = cc.approx_if * cam.params(1:2);
                cam.params(3:4) = cc.approx_if * (cam.params(3:4) - cc.approx_pp);
            case 'OPENCV_FISHEYE'     	% fx, fy, cx, cy, k1, k2, k3, k4
                cam.params(1:2) = cc.approx_if * cam.params(1:2);
                cam.params(3:4) = cc.approx_if * (cam.params(3:4) - cc.approx_pp);
            case 'FULL_OPENCV'          % fx, fy, cx, cy, k1, k2, p1, p2, k3, k4, k5, k6   
                cam.params(1:2) = cc.approx_if * cam.params(1:2);
                cam.params(3:4) = cc.approx_if * (cam.params(3:4) - cc.approx_pp);
           otherwise
                cam.params(1) = cc.approx_if * cam.params(1);
                cam.params(2:3) = cc.approx_if * (cam.params(2:3) - cc.approx_pp);
        end
        cam.width = 1;
        cam.height = cc.approx_if * cam.height;
        cams2(cam.camera_id) = cam; 
        cams_change(cam.camera_id) = cc; 
    end
    % 6.2) images
    c_imgs = d.images.values;
    for i = 1:length(c_imgs)
        img = c_imgs{i};
        cc = cams_change(img.camera_id);
        img.xys = cc.approx_if * (img.xys' - cc.approx_pp)';
        d.images(img.image_id) = img;
    end
    % 6.3) apply new cams 
    d.cameras = cams2;
    
end

