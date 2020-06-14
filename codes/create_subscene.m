function [ scene ] = create_subscene( d, selected_images )
%GENERATE_SUBSCENE - load scene from file and generate subscene with given
%number of images

    % generate scene with selected images
    tic; fprintf('> compose subscene ...') 
    
    % 1) add camera
    g_cams = containers.Map('KeyType','int64','ValueType','any');
    c_cams = d.cameras.values();
    g_cams(1) = c_cams{1};
    
    % 2) add images
    used_X = zeros(1,length(d.points3D));
    g_imgs = containers.Map('KeyType','int64','ValueType','any');
    for i = 1:length(selected_images)
        img = d.images(selected_images(i));
        img.camera_id = 1;    %cams_to_group(k);  % originaly has each image its own camera

        % filter multiple points assign to one point in 3D
        filter = find(img.point3D_ids ~= -1);
        [p3D_ids, unique_ids] = unique(img.point3D_ids(filter));
        unique_filter = filter(unique_ids);
        img.point3D_ids = -ones(length(img.point3D_id),1);

        [~,IA,IB] = intersect(cell2mat(d.points3D.keys)', p3D_ids);
        used_X(IA) = used_X(IA) + 1;
        img.point3D_ids(unique_filter(IB)) = p3D_ids(IB);
        

        % add standard deviation of error
        img.xys_std = repmat([1 0 0 1],size(img.xys,1),1);
        img.xys_cov = repmat([1 0 0 1],size(img.xys,1),1);
        
        g_imgs(img.image_id) = img;
    end
    
    % 3) add points in 3D
    g_points3D = containers.Map('KeyType','int64','ValueType','any');
    c_points3D = d.points3D.values;
    c_points3D = c_points3D(used_X > 1);
    for k = 1:size(c_points3D,2)
        g_points3D(c_points3D{k}.point3D_id) = c_points3D{k};
    end

    % 4) filter the observations and points in 3D
    p3Dkeys = cell2mat(d.points3D.keys);
    remove_pts = p3Dkeys(used_X < 2);
    cg_imgs = g_imgs.values;
    for k = 1:size(cg_imgs,2)
        img = cg_imgs{k};
        [~,IA,~] = intersect(img.point3D_ids, remove_pts);
        img.point3D_ids(IA) = -1;
        g_imgs(img.image_id) = img;
    end
    for i = 1:length(remove_pts)
        if isKey(g_points3D,remove_pts(i))
            remove(g_points3D,remove_pts(i));
        end
    end

    % 5) compose output scene
    scene = struct();
    scene.cameras = g_cams;
    scene.images = g_imgs;
    scene.points3D = g_points3D;
    fprintf('%.2fsec\n',toc)
end

