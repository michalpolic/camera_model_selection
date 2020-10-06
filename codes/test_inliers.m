function [ res ] = test_inliers( d, reproj_threshold )
%TEST_INLIERS - compute the statistic about inliers detection using
%different kind of threshold criteria 

    % init results array
    res = cell(1,length(reproj_threshold));
    for j = 1:length(reproj_threshold)
        s = struct();
        s.inliers = [];
        s.reproj_inliers = [];
        s.weighted_reproj_inliers = [];
        res{j} = s;
    end
    
    % test the projections
    c_imgs = d.images.values;
    for i = 1:length(c_imgs)
        fprintf(repmat('\b',1,4));
        fprintf('%03d%%',ceil(100*i/length(c_imgs)));
        
        img = c_imgs{i};
        cam = d.cameras(img.camera_id);
        
        % pts
        reconst_filter = img.point3D_ids ~= -1;
        pt3D_ids = img.point3D_ids(reconst_filter);
        [~,~,IB] = intersect(cell2mat(d.points3D.keys),pt3D_ids);
        pts = arrayfun(@(pt_id) d.points3D(pt_id).xyz, pt3D_ids(IB), 'UniformOutput', false);
        if ( size(pts,1) ~= 1 )
            pts = pts';
        end
        X = cell2mat(pts);
        
        % proj
        u_proj = proj( cam, img, X );
        
        % covariances
        C = img.xys_cov(IB,:)';
        
        % reprojection error 
        err = u_proj - img.xys(IB,:)';
        D = sqrt(sum(err.^2));
        D_norm = arrayfun(@(j) sqrt(sum((inv(reshape(C(:,j),2,2)) * err(:,j)).^2)), 1:length(D));

        % reprojection error clasification 
        % 1) without normalization
        % 2) with normalization
        for j = 1:length(reproj_threshold)
            s = res{j};
            s.inliers = [s.inliers img.inliers'];
            s.reproj_inliers = [s.reproj_inliers D<reproj_threshold(j)];
            s.weighted_reproj_inliers = [s.weighted_reproj_inliers D_norm<reproj_threshold(j)];
            res{j} = s;
        end

    end


end

