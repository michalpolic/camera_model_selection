function [ scene ] = add_obs_variance( scene, setting )
%ADD_OBS_VARIANCE - add variance to the image parameters
    
    % find some sigma to assign 
    if exist('setting','var')
        if isstruct(setting) && isfield(setting,'sigma')
            sigma2 = setting.sigma.^2;
        else
            sigma2 = 1;
        end
    else
        sigma2 = 1;
    end

    c_imgs = scene.images.values;
    for i = 1:size(c_imgs,2)
        img = c_imgs{i};
        if ~isfield(img,'xys_cov')
            img.xys_cov = repmat([sigma2 0 0 sigma2],size(img.xys,1),1);
        end
        if ~isfield(img,'xys_std')
            img.xys_std = repmat([sqrt(sigma2) 0 0 sqrt(sigma2)],size(img.xys,1),1);
        end
        scene.images(img.image_id) = img;
    end
end

