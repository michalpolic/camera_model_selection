function [ scene ] = sceneCell2Map( cell_scene )
%SCENECELL2MAP - transform the colmap scene from cells into Map containers

    scene = struct();
    scene.cameras = containers.Map('KeyType','int64','ValueType','any');
    scene.images = containers.Map('KeyType','int64','ValueType','any');
    scene.points3D = containers.Map('KeyType','int64','ValueType','any');
    
    c_cameras = cell_scene.cameras;
    for i = 1:size(c_cameras,2)
        cam = c_cameras{i};
        scene.cameras(int64(cam.camera_id)) = cam;
    end
    
    c_images = cell_scene.images;
    for i = 1:size(c_images,2)
        img = c_images{i};
        scene.images(int64(img.image_id)) = img;
    end
    
    c_points3D = cell_scene.points3D;
    for i = 1:size(c_points3D,2)
        pt = c_points3D{i};
        scene.points3D(int64(pt.point3D_id)) = pt;
    end
end

