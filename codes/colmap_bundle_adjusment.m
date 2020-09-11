function [ scene ] = colmap_bundle_adjusment( scene, tmp_dir, colmap_root_path )
%COLMAP_BUNDLE_ADJUSMENT - run the BA on colmap scene
    
    % save the colmap reconstruction
    if ~exist(tmp_dir,'dir')
        mkdir(tmp_dir);
    end
    tmp_dir_txt = fullfile(tmp_dir,'txt_scene');
    if ~exist(tmp_dir_txt,'dir')
        mkdir(tmp_dir_txt);
    end
    tmp_dir_bin = fullfile(tmp_dir,'bin_scene');
    if ~exist(tmp_dir_bin,'dir')
        mkdir(tmp_dir_bin);
    end
    saveColmap( tmp_dir_txt, scene.cameras, scene.images, scene.points3D );

    % go to the colmap lib dir
    actual_path = pwd;
    cd(fullfile(colmap_root_path,'lib'));
    colmap_executable = strrep(fullfile(colmap_root_path,'bin','colmap'),'\','/');
    
    % rewrite txt files into bin files (required by BA)
    txt2bin = sprintf('%s.exe model_converter --input_path %s --output_type BIN --output_path %s',...
              colmap_executable, tmp_dir_txt, tmp_dir_bin);
    [status,cmdout] = system(txt2bin);
    
    % run bundle adjustment
    ba = sprintf('%s.exe bundle_adjuster --input_path %s --output_path %s',...
              colmap_executable, tmp_dir_bin, tmp_dir_bin);
    [status,cmdout] = system(ba)
    
    % rewrite the optimized scene to txt (required to load scene)
    bin2txt = sprintf('%s.exe model_converter --input_path %s --output_type TXT --output_path %s',...
              colmap_executable, tmp_dir_bin, tmp_dir_txt);
    [status,cmdout] = system(bin2txt);
    
    % go back to original dir 
    cd(actual_path);
    
    % load optimized colmap scene
    [scene.cameras, scene.images, scene.points3D] = read_model(tmp_dir_txt);
end

