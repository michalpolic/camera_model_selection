function [ d ] = filter_dataset_errors( d )
%FILTER_DATASET_ERRORS - remove the errors in COLMAP dataset
    
    p3D_used = zeros(1,size(d.points3D,1));
    all_p3d_ids = cell2mat(d.points3D.keys);
    
    c_imgs = d.images.values;
    for j = 1:size(d.images,1)
        img = c_imgs{j};

         % all pts 3D exist
        reconst_filter = img.point3D_ids ~= -1;
        pt3D_ids = img.point3D_ids(reconst_filter);
        xys = img.xys(reconst_filter,:);
        if isfield(img,'xys_cov')
            xys_cov = img.xys_cov(reconst_filter,:);
        end
        if isfield(img,'xys_std')
            xys_std = img.xys_std(reconst_filter,:);
        end
        
        % test correspondences
        if isempty(pt3D_ids)
            warning('Residuals cannot be computed because the image %d hase no corespondences.',img.image_id);
        end
        
        % test non-existing points and repetetive points in 3D
        [~,IA,IB] = intersect(all_p3d_ids, pt3D_ids);
        if length(pt3D_ids) ~= length(IB)           
            fprintf('> filter %d non-existing points from img %d\n',length(pt3D_ids)-length(IB),img.image_id)
        end
        
        % all pts 3D have to be used at least 2 times
        p3D_used(IA) = p3D_used(IA) + 1;
        
        % save
        img.point3D_ids = pt3D_ids(IB);
        img.xys = xys(IB,:);
        if isfield(img,'xys_cov')
            img.xys_cov = xys_cov(IB,:);
        end
        if isfield(img,'xys_std')
            img.xys_std = xys_std(IB,:);
        end
        d.images(img.image_id) = img;
    end

    % test if all pts 3D are used at least 2 times
    if sum(p3D_used > 1) ~= size(p3D_used,2)
        fprintf('> filter %d points in 3D without enough correspondeces\n',sum(p3D_used < 2))
    end

    % remove points in 3D without enough correspondeces
    remove_pts = all_p3d_ids(p3D_used < 2);
    for i = 1:length(remove_pts)
        if isKey(d.points3D,remove_pts(i))
            remove(d.points3D,remove_pts(i));
        end
    end
    
    % remove obs which see not existing or removed point in 3D
    c_imgs = d.images.values;
    for i = 1:size(c_imgs,2)
        img = c_imgs{i};
        [~,IA,~] = intersect(img.point3D_ids,remove_pts);
        img.xys(IA,:) = [];
        img.point3D_ids(IA) = [];
        if isfield(img,'xys_cov')
            img.xys_cov(IA,:) = [];
        end
        if isfield(img,'xys_std')
            img.xys_std(IA,:) = [];
        end
        d.images(img.image_id) = img;
    end
end

