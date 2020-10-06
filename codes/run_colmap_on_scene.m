function [cameras, images, points3D] = run_colmap_on_scene( scene, max_error, project_dir, colmap_root_path )
%SAVE_COLMAP_DB - save colmap observations into database

    tic; fprintf('> run COLMAP on predefined observations ... ') 
    
    % init project dir
    if exist(project_dir,'dir')
        status = 0;
        while (status == 0)
            [status, ~, ~] = rmdir(project_dir,'s'); 
        end
    end
    imgs_dir = fullfile(project_dir,'images');
    database_path = fullfile(project_dir,'database.db');
    mkdir(project_dir);
    mkdir(imgs_dir);
    
    % setup run path
    actual_path = pwd;
    if exist(fullfile(colmap_root_path,'colmap.exe'),'file')
        % custom build
        cd(colmap_root_path);
        colmap_executable = strrep(fullfile(colmap_root_path,'colmap'),'\','/');
    elseif exist(fullfile(colmap_root_path,'lib'),'dir') &&  exist(fullfile(colmap_root_path,'bin'),'dir')
        % downloaded binaries
        cd(fullfile(colmap_root_path,'lib'));
        colmap_executable = strrep(fullfile(colmap_root_path,'bin','colmap'),'\','/');
    else
        error('run_colmap_on_scene: incorrect colmap_root_path')
    end
    
    % save existing observations with randomly generated feature vectors
    % 1) generate random descriptors
    p3D_ids = cell2mat(scene.points3D.keys);
    descriptors = randi(256,size(scene.points3D,1),128)-1;      
    
    c_images = scene.images.values;
    K = size(c_images,2);                   % K ... number of images in dataset
    for i = 1:K
        img = c_images{i};
        cam = scene.cameras(img.camera_id);
        
        % 2) save fake images
        img.name = sprintf('%04d.jpg',i);
        imwrite(ones(cam.height,cam.width),fullfile(imgs_dir,img.name),'JPEG');   
        
        % 3) save corresponding keypoints and descriptors
        filter = img.point3D_ids ~= -1;
        img_point3D_ids = img.point3D_ids(filter);
        obs = img.xys(filter,:);
        img.xys = obs;
        img.point3D_ids = img_point3D_ids;
        c_images{i} = img;
        
        descr_rows = arrayfun(@(id) descriptors(p3D_ids == id,:), img_point3D_ids, 'UniformOutput', false);
        fileID = fopen(fullfile(imgs_dir,sprintf('%04d.jpg.txt',i)),'w');
        fprintf(fileID,'%d 128\n',size(descr_rows,1));
        for j = 1:size(descr_rows,1)
            fprintf(fileID,'%f %f 1 1',obs(j,1),obs(j,2));
            fprintf(fileID,' %d',descr_rows{j});
            fprintf(fileID,'\n');
        end
        fclose(fileID);
    end
    
    
    %import features
    c_cams = scene.cameras.values;
    cam_model = c_cams{1}.model;
    import_features = sprintf(['%s.exe feature_importer --database_path %s --image_path %s ' ...
        '--import_path %s --ImageReader.camera_model %s --ImageReader.single_camera 1'],...
        colmap_executable, database_path, imgs_dir, imgs_dir, cam_model);
    [status,cmdout] = system(import_features);
    
    
    % save matches
    fileID = fopen(fullfile(project_dir,'matches.txt'),'w');
    % 1) compose graph of image paris
    G = cell(K);
    for i = 1:K                         % save pts 3D on diagonal
        G{i,i} = struct();
        G{i,i}.name = strtrim(c_images{i}.name);
        G{i,i}.pt_ids = int32(c_images{i}.point3D_ids);
    end
    for i = 1:K                         % compute the camera pairs
        for j = i+1:K
            [~,IA,IB] = intersect(G{i,i}.pt_ids,G{j,j}.pt_ids);
            if ~isempty(IA)
                % 2) save pairs of images and observations
                fprintf(fileID,'%s %s\n', G{i,i}.name, G{j,j}.name);
                for k = 1:size(IA,1)
                    fprintf(fileID,'%d %d\n', IA(k)-1, IB(k)-1);
                end
                fprintf(fileID,'\n');
            end
        end 
    end
    fclose(fileID);
    
    % match features
    match_features_command = sprintf(['%s.exe matches_importer --database_path %s ' ...
        '--match_list_path %s --match_type raw --SiftMatching.max_error %f'],...
        colmap_executable, database_path, fullfile(project_dir,'matches.txt'), max_error);
    [status,cmdout] = system(match_features_command);

    % sfm - verify and find tracks
    sfm_command =  sprintf(['%s.exe mapper --database_path %s --image_path %s --output_path %s' ...
        ' --Mapper.tri_complete_max_reproj_error %d --Mapper.tri_merge_max_reproj_error %d' ...
        ' --Mapper.abs_pose_max_error %d --Mapper.init_max_error %d --Mapper.init_min_num_inliers 10'],...
        colmap_executable, database_path,imgs_dir, project_dir,max_error,max_error,max_error,max_error);
    [status,cmdout] = system(sfm_command);

    % save sfm as txt files
    sfm_bin2txt_command =  sprintf('%s.exe model_converter --input_path %s --output_type TXT --output_path %s',...
        colmap_executable, fullfile(project_dir,'0'),project_dir);
    [status,cmdout] = system(sfm_bin2txt_command);
    cd(actual_path);

    % read the reconstruction
    if (    exist(fullfile(project_dir,'cameras.txt'),'file') && ...
            exist(fullfile(project_dir,'images.txt'),'file') && ...
            exist(fullfile(project_dir,'points3D.txt'),'file')   )
        [cameras, images, points3D] = read_model(project_dir);
    else
        cameras = [];
        images = [];
        points3D = [];
    end
    fprintf('%.2fsec\n',toc)
end
