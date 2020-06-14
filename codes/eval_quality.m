function [ res, scene ] = eval_quality( res, sparse_reconstr, colmap_prexif, gt_sparse_reconstr )
%EVAL_QUALITY - load the best SfM results and save statistics about scene 

    % 3a) load evaluated recontsructions
    % go over all models, read the largest
    directories = dir(sparse_reconstr);
    directories = directories(3:end);
    if isempty(directories)
        scene = [];
        res.failed = 1;
        return;
    else
        res.failed = 0;
    end
    actual_path = pwd;
    cd(fullfile(colmap_prexif,'lib','colmap')); 
    colmap_executable = strrep(fullfile(colmap_prexif,'bin','colmap'),'\','/');
    nimgs = zeros(1, length(directories));
    for i = 1:length(directories)
        rec_dir = fullfile(directories(i).folder,directories(i).name);
        system(sprintf('%s model_converter --input_path %s --output_path %s --output_type TXT', ...
                        colmap_executable,rec_dir,rec_dir));
        [~, images, ~] = read_model(rec_dir); 
        nimgs(i) = length(images);  
    end
    cd(actual_path);
    
    
    % 3b) measure num. of images, points, observations
    [~, max_rec_id] = max(nimgs);
    largest_rec_dir = fullfile(directories(max_rec_id).folder, directories(max_rec_id).name);
    [cameras, images, points3D] = read_model(largest_rec_dir); 

    res.ncams = length(cameras);   
    res.nimgs = length(images);            
    res.npts = length(points3D);  
    res.nobs = 0;
    res.nobs_all = 0;
    c_imgs = images.values();
    res.residuals = cell(length(c_imgs),1);
    for k = 1:length(c_imgs)
        img = c_imgs{k};
        cam = cameras(img.camera_id);
        res.residuals{k} = compute_residuals( img, cam, points3D );
        res.nobs = res.nobs + length(res.residuals{k});
        res.nobs_all = res.nobs_all + size(img.xys,1);
    end
    scene = struct('cameras',cameras,'images',images,'points3D',points3D);

    
    % 3c) if GT exist, evaluate the camera centers distances
    if exist('gt_sparse_reconstr','var') && ~isempty(gt_sparse_reconstr)
        [~, gt_images, ~] = read_model(gt_sparse_reconstr); 
        
        % find corresponding images
        c_imgs = images.values();
        c_gt_imgs = gt_images.values();
        C = zeros(3,length(c_imgs));
        gt_C = nan(3,length(c_imgs));
        for i = 1:length(c_imgs)
            img = c_imgs{i};
            [~,b,c] = fileparts(img.name);
            img_name = strtrim([b c]);
            C(:,i) = - img.R' * img.t;
            for j = 1:length(c_gt_imgs)
                gt_img = c_gt_imgs{j};
                [~,b2,c2] = fileparts(gt_img.name);
                if strcmp(img_name, strtrim([b2 c2]))
                    gt_C(:,i) = - gt_img.R' * gt_img.t;
                end
            end
        end
        
        % fit camera centers
        [~, C_fit, tr] = procrustes(gt_C', C');                         
        C_fit = C_fit';
        res.tranf2GT = struct('R',tr.T', 't',tr.c(1,:)', 's',tr.b);     % C_fit = tr.b * tr.T' * C + tr.c';

%         % show the fit
%         figure(); hold on; axis equal; %plot3(C(1,:),C(2,:),C(3,:),'r.'); 
%         plot3(gt_C(1,:),gt_C(2,:),gt_C(3,:),'g.');
%         plot3(C_fit(1,:),C_fit(2,:),C_fit(3,:),'b.');
        
        % mean distance 
        res.res_cam_centers = sqrt(sum((gt_C - C_fit).^2));
        res.Q = mean(res.res_cam_centers);     
    end
    
end

