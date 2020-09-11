function [ scene ] = calib_to_colmap( file )
%CALIBSESION_TO_COLMAP - transform Matlab calibration session to COLMAP
%scene

    % load
    if ~exist(file,'file')
        error('Calibration session path is not correct.');
    end
    load(file);
    if ~exist('calibrationSession','var')
        error('Calibration session is corrupted.');
    end
    
    % rewrite 
    cs = calibrationSession;
    cs_cam = cs.CameraParameters;
    cs_board = cs.BoardSet;

    % create scene 
    scene = struct();
    scene.cameras = containers.Map('KeyType','int64','ValueType','any');
    scene.images = containers.Map('KeyType','int64','ValueType','any');
    scene.points3D = containers.Map('KeyType','int64','ValueType','any');
    % camera
    scene.cameras(1) = struct('camera_id',1.0,'model','RADIAL',...
        'width',cs_cam.ImageSize(2),'height',cs_cam.ImageSize(1),...
        'params', [mean(cs_cam.FocalLength) cs_cam.PrincipalPoint cs_cam.RadialDistortion]');
    % images
    nimgs = size(cs_cam.RotationMatrices,3);
    for i = 1:nimgs
        R = cs_cam.RotationMatrices(:,:,i);
        t = cs_cam.TranslationVectors(i,:)';
        scene.images(i) = struct('image_id',double(i),'q',r2q(R'),'R',R','t',t,...
            'camera_id',1,'name',cs_board.FullPathNames(i),...
            'xys',cs_board.BoardPoints(:,:,i),'point3D_ids',[1:length(cs_board.BoardPoints(:,:,i))]');
    end
    % pts in 3D
    for i = 1:size(cs_board.WorldPoints,1)
        scene.points3D(i) = struct('point3D_id',i,...
            'xyz',[cs_board.WorldPoints(i,:) 0]','rgb',int8([0;0;0]),...
            'error',0,'track',[1:nimgs; i*ones(1,nimgs)]');
    end

end

