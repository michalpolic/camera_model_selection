function [ d ] = adjust_keypoints( dataset, cam_params, setting )
%ADJUST_KEYPOINTS - adjust the scene, add missmatches, add covariances of
%keypoints
    
    % load original dataset 
    tic; fprintf('> loading of the original dataset ...')
    if isstruct(dataset)
        d = clone_scene(dataset);
    else
        if exist(dataset,'dir')
            d = struct();
            [d.cameras, d.images, d.points3D] = read_model(dataset); 
        else
            warning('adjust_keypoints: the "dataset" variable does not match required input')
            return;
        end
    end
    fprintf('%.2fsec\n',toc)
    
    % filter datasets mistakes
    tic; fprintf('> filter dataset mistakes ...\n')
    d = filter_dataset_errors(d);
    fprintf('> filter dataset mistakes ... %.2fsec\n',toc)
    
    % update cameras to new camera model
    d.cameras = containers.Map('KeyType','int64','ValueType','any');
    new_cam = cam_params.camera_models.(setting.cam_model);
    d.cameras(1) = new_cam;
%     c_imgs = d.images.values; 
%     for i = 1:length(c_imgs)
%         img = c_imgs{i};
%         img.camera_id = 1;
%         d.images(img.image_id) = img;
%     end
    
%     % optimize the real camera parameters to correct dataset
%     tic; fprintf('> optimize radial distortion to scene ...')
%     opt = struct('alg','JACOBIAN_ESTIMATOR','in_cov','UNIT','run_opt',1,'run_opt_radial',1);
%     d = add_obs_variance(d, 1);
%     [~, cell_d_lo] = usfm_mex(opt, d.cameras.values, d.images.values, d.points3D.values);
%     d = sceneCell2Map( cell_d_lo ); 
%     fprintf('%.2fsec\n',toc)
    
    % update projections ( add error derived from covariances form ETH dataset )
    if isfield(setting,'keypoints_covariances')
        nkcov = length(setting.keypoints_covariances);
    end
    c_imgs = d.images.values; 
    for i = 1:length(c_imgs)
        % load, find observations
        img = c_imgs{i};
        img.camera_id = 1;
        cam = d.cameras(img.camera_id);
        reconst_filter = img.point3D_ids ~= -1;
        pt3D_ids = img.point3D_ids(reconst_filter);
        
        % test the scene 
        if isempty(pt3D_ids)
%             warning('Residuals cannot be computed because the image %d hase no reprojections.',img.image_id);
        end
        [~,~,IB] = intersect(cell2mat(d.points3D.keys),pt3D_ids);
        if size(IB,1) ~= size(pt3D_ids,1)
%             warning('The image %d contains point in 3D id which does not exist.',img.image_id);
        end

        % projections of points
        pts = arrayfun(@(pt_id) d.points3D(pt_id).xyz, pt3D_ids(IB), 'UniformOutput', false);
        if ( size(pts,1) ~= 1 )
            pts = pts';
        end
        X = cell2mat(pts);
        u_proj = proj( cam, img, X );

        
        % filter by the field of view and maximal calibration radial distance
        filter = filter_field_of_view( u_proj', new_cam );
        if isfield(new_cam,'max_r')
            filter = filter & (sqrt(sum(h2a(img.R * X + img.t).^2)) < new_cam.max_r)';
        end
        
        % save new observations & add noise
        img.xys = u_proj(:,filter)';
        img.xys_cov = zeros(size(img.xys,1),4);
        img.point3D_ids = pt3D_ids(IB(filter));
        for j = 1:size(img.xys,1)
            if isfield(setting,'keypoints_noise') && strcmp(setting.keypoints_noise,'UNIFORM')
                E = reshape(setting.noise_level * eye(2,2),4,1);
                C = reshape(sqrt(setting.noise_level) * eye(2,2),4,1);
            else
                cov_id = randi(nkcov);
                C = setting.keypoints_covariances(:,cov_id);
                E = setting.keypoints_elipsoids(:,cov_id);
            end
            img.xys(j,:) = img.xys(j,:) + (reshape(E,2,2) * randn(2,1))';
            img.xys_std(j,:) = E';
            img.xys_cov(j,:) = C';
        end
        d.images(img.image_id) = img;
    end

    
    % remove images with no observations 
    c_imgs = d.images.values;
    for i = 1:length(c_imgs)
        img = c_imgs{i};
        reconst_filter = img.point3D_ids ~= -1;
        pt3D_ids = img.point3D_ids(reconst_filter);
        if isempty(pt3D_ids)
            if isKey(d.images,img.image_id)
                remove(d.images,img.image_id);
            end
        end
    end

    
    % filter datasets mistakes
    tic; fprintf('> filter dataset mistakes ...\n')
    d = filter_dataset_errors(d);
    fprintf('> filter dataset mistakes ... %.2fsec\n',toc)
    
end
