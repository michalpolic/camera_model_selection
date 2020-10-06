function test_scene( d )
%TEST_SCENE - test colmap scene properties

    used_X = zeros(1,size(d.points3D,1));
    p3d_ids = cell2mat(d.points3D.keys);
    
    c_imgs = d.images.values;
    for j = 1:size(d.images,1)
        img = c_imgs{j};
        
         % all pts 3D exist
        f = img.point3D_ids ~= -1;
        img_p3d_ids = img.point3D_ids(f);
        
        [~,IA,IB] = intersect(img_p3d_ids, p3d_ids);
        if length(img_p3d_ids) ~= length(IA)           
            warning('Error: image %d contains 3D points which does not exist',img.image_id);
        end
        
        if length(img.point3D_ids) ~=  length(unique(img.point3D_ids))
            warning('Error: image %d contains repetetive 3D point',img.image_id);
        end
            
        if ~isfield(img,'xys_cov')
           warning('Img %d miss the xys_cov field',img.image_id) 
        else
            if size(img.xys,1) ~= size(img.xys_cov,1)
                warning('Img %d - wrong number of xys %d or xys_cov %d.',img.image_id, size(img.xys,1), size(img.xys_cov,1))
            end
        end
        
        if ~isfield(img,'xys_std')
           warning('Img %d miss the xys_std field',img.image_id) 
        else
            if size(img.xys,1) ~= size(img.xys_std,1)
                warning('Img %d - wrong number of xys %d or xys_std %d.',img.image_id, size(img.xys,1), size(img.xys_std,1))
            end
        end
        
        if size(img.xys,1) ~= size(img.point3D_ids,1)
            warning('Img %d - wrong number of observations %d or points ids %d.',img.image_id, size(img.xys,1), size(img.point3D_ids,1))
        end
        
        % all pts 3D are used at least 2 times
        used_X(IB) = used_X(IB) + 1;
    end

    % all pts 3D are used at least 2 times
    if sum(used_X > 1) ~= size(used_X,2)
        warning('Error: there is point in 3D with less than 2 observations');
    end
    
end

