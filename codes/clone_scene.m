function [ cloned_scene ] = clone_scene( scene )
%CLONE_SCENE - clone the scene
    cloned_scene = struct();
    cloned_scene.cameras = containers.Map('KeyType','int64','ValueType','any');
    cloned_scene.images = containers.Map('KeyType','int64','ValueType','any');
    cloned_scene.points3D = containers.Map('KeyType','int64','ValueType','any');
    
    c_cameras = scene.cameras.values;
    for i = 1:size(c_cameras,2)
        cam = c_cameras{i};
        cloned_scene.cameras(cam.camera_id) = cam;
    end
    
    c_images = scene.images.values;
    for i = 1:size(c_images,2)
        img = c_images{i};
        cloned_scene.images(img.image_id) = img;
    end
    
    c_points3D = scene.points3D.values;
    for i = 1:size(c_points3D,2)
        pt = c_points3D{i};
        cloned_scene.points3D(pt.point3D_id) = pt;
    end
end

