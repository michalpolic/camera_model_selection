function d_sub = subscene_Se( d, max_error )
% subscene_Se - compose subscene with reprojection error < max_error

    min_num_obs = 4;

    % subscene Se
    d_sub = clone_scene(d);
    d_tmp = clone_scene(d);
    
    % remove old tracks in d_tmp
    p3D_ids = cell2mat(d_sub.points3D.keys);
    for i = 1:length(p3D_ids)
        p3d = d_tmp.points3D(p3D_ids(i));
        p3d.track = [];
        d_tmp.points3D(p3D_ids(i)) = p3d;
    end
    
    % find the observations with smaller error
    p3D_used = zeros(1,size(d_sub.points3D,1));
    c_imgs = d_sub.images.values;
    u_err = containers.Map('KeyType','int64','ValueType','any');
    filter_ids = cell(1,size(c_imgs,2));
    for i = 1:size(c_imgs,2)
        img = c_imgs{i};
        cam = d_sub.cameras(img.camera_id);
        
        % projections 
        [u_obs, X, X_ids, filter_ids{i}] = img_uX(img, d_sub);
%         size(X)
        u_proj = proj( cam, img, X );

        % reprojection error 
        err = u_proj - img.xys(filter_ids{i},:)';
        
        % inliers clasification 
        if ~isfield(img,'xys_std')
            % 1) without normalization
            D = sqrt(sum(err.^2));
            u_used = sqrt(sum(err.^2)) < max_error;
        else
            % 2) with normalization
            E = img.xys_std(filter_ids{i},:)';      % covariances
            D = sqrt(sum(err.^2));
            nfD = sum(E) ~= 0;
            D(nfD) = arrayfun(@(j) sqrt(sum((inv(reshape(E(:,j),2,2)) * err(:,j)).^2)), find(nfD));
            u_used = D < max_error;   
        end
        u_err(img.image_id) = D;
        
        % filter
        [~,~,IB] = intersect(X_ids(u_used),p3D_ids);
        p3D_used(IB) = p3D_used(IB) + 1;
        
        % remove observations with err > max_error
        if isfield(img,'xys_cov')
            img.xys_cov(~u_used,:) = [];
        end
        if isfield(img,'xys_std')
            img.xys_std(~u_used,:) = [];
        end
        if isfield(img,'inliers')
            img.inliers(~u_used,:) = [];
        end
        img.xys(~u_used,:) = [];
        img.point3D_ids(~u_used) = [];
        %X_ids(~u_used) = [];
        
        % add tracks to p3D
        for j = 1:size(X_ids,1)
            p3d = d_tmp.points3D(X_ids(j));
            p3d.track = [p3d.track; img.image_id j];  %u_ids(j)
            d_tmp.points3D(X_ids(j)) = p3d;
        end
            
        d_sub.images(img.image_id) = img;
        %d_sub.cameras(img.camera_id) = cam;
    end
        
    % remove points in 3D
    remove_ids = p3D_ids(p3D_used < 2);
    for i = 1:length(remove_ids)
        if isKey(d_sub.points3D,remove_ids(i))
            remove(d_sub.points3D,remove_ids(i));
        end
        if isKey(d_tmp.points3D,remove_ids(i))
            remove(d_tmp.points3D,remove_ids(i));
        end
    end
    
    % remove obs which see not existing point in 3D
    c_imgs = d_sub.images.values;
    for i = 1:size(c_imgs,2)
        img = c_imgs{i};
        [~,IA,~] = intersect(img.point3D_ids,remove_ids);
        if isfield(img,'xys_cov')
            img.xys_cov(IA,:) = [];
        end
        if isfield(img,'xys_std')
            img.xys_std(IA,:) = [];
        end
        if isfield(img,'inliers')
            img.inliers(IA,:) = [];
        end
        img.xys(IA,:) = [];
        img.point3D_ids(IA) = [];
        d_sub.images(img.image_id) = img;
    end
    
    
    
    
    % test if all images has enough observations to be unambigously determined
    c_imgs = d.images.values;
    c_imgs_sub = d_sub.images.values;
    for i = 1:size(c_imgs,2)
        img = c_imgs{i};
        img_sub = c_imgs_sub{i};
        
        % add observations to have at least min number of observations
        if size(img_sub.point3D_ids,1) < min_num_obs
            % error of adding observation
            [obs_err, sort_ids] = sort(u_err(img.image_id));
            p3d_ids = img.point3D_ids(filter_ids{i}(sort_ids));
            obs = img.xys(filter_ids{i}(sort_ids),:);
            cov = img.xys_cov(filter_ids{i}(sort_ids),:);
            std = img.xys_std(filter_ids{i}(sort_ids),:);
            
            % add_prop = [[img1; obs1[u;v]; p3d1; err; cov; std; img2; obs2[u;v]; cov2; std2],...] 
            add_prop = zeros(24,size(obs_err,2)); 
            add_prop(1,:) = img.image_id;       % img1
            add_prop([2;3],:) = obs';           % obs1 [u;v]
            add_prop(4,:) = p3d_ids';           % p3did
            add_prop(5,:) = inf;                % error
            add_prop([6;7;8;9],:) = cov';       % cov
            add_prop([10;11;12;13],:) = std';   % std
            
            for j = 1:size(add_prop,2)
                if ~isKey(d_tmp.points3D, add_prop(4,j))
                    continue;
                end
                
                p3d = d_tmp.points3D(add_prop(4,j));
                for k = 1:size(p3d.track,1)     % each point 3D has several obs. -> we want to add the one with smalles err.
                    track_img_id = p3d.track(k,1);
                    if track_img_id == img.image_id
                        continue;
                    end
                    % save minimal reprojection error for our track
                    u_err_img = u_err(track_img_id);
                    e = u_err_img(p3d.track(k,2));
                    if e < add_prop(5,j)
                        add_prop(5,j) = e;
                        add_prop(14,j) = track_img_id;
                        obs_id = filter_ids{find(cell2mat(d.images.keys) == track_img_id)}(p3d.track(k,2));
                        add_prop([15;16],j) = d.images(track_img_id).xys(obs_id,:)';
                        add_prop([17;18;19;20],j) = d.images(track_img_id).xys_cov(obs_id,:)';
                        add_prop([21;22;23;24],j) = d.images(track_img_id).xys_std(obs_id,:)';
                    end
                end
            end
            
            
            
            % sort the additional obs. w.r.t. sum of all additional errors
            add_prop(5,:) = add_prop(5,:) + obs_err;
            [~,sort_ids] = sort(add_prop(5,:));
            add_prop = add_prop(:,sort_ids);
            
            % remove Matlab error (empty array has size 1)
            if isempty(img_sub.point3D_ids)
                img_sub.point3D_ids = [];
            end
            
            % add required number of observations which does 
            j = 1;
            while (min_num_obs - size(img_sub.point3D_ids,1) > 0)
                % remove images which cannot be added
                if j > size(add_prop,2) || isinf(add_prop(5,j))
                    remove(d_sub.images,img_sub.image_id);
                    break;
                end
                if ~isKey(d_sub.images,add_prop(14,j))
                    continue;
                end    
                
                % check if the image1 contains selected point in 3D
                if( sum(img_sub.point3D_ids == add_prop(4,j)) == 0 )
                    % add obs1 to the selected image1
                    img_sub.xys(end+1,:) = add_prop([2;3],j)';
                    img_sub.point3D_ids(end+1,1) = add_prop(4,j);
                    img_sub.xys_cov(end+1,:) = add_prop([6;7;8;9],j)';
                    img_sub.xys_std(end+1,:) = add_prop([10;11;12;13],j)';
                    d_sub.images( img_sub.image_id ) = img_sub;
                    
                    % check if the image2 contains selected point in 3D
                    if( sum(d_sub.images(add_prop(14,j)).point3D_ids == add_prop(4,j)) == 0)
                        % add observation
                        img_sub2 = d_sub.images(add_prop(14,j));
                        img_sub2.xys(end+1,:) = add_prop([15;16],j)';
                        img_sub2.xys_cov(end+1,:) = add_prop([17;18;19;20],j)';
                        img_sub2.xys_std(end+1,:) = add_prop([21;22;23;24],j)';
                        img_sub2.point3D_ids(end+1,1) = add_prop(4,j);
                        d_sub.images(img_sub2.image_id) = img_sub2;  

                        % add p3d
                        p3d = d.points3D(add_prop(4,j));
                        d_sub.points3D(p3d.point3D_id) = p3d;
                    end
                end
                j = j + 1;
            end
        end
    end
    
    
    d_sub = filter_dataset_errors(d_sub);
end
    
