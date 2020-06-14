function [cmdout] = run_sfm(database_path, imgs_dir, sparse_reconstr, colmap_root_path)
%RUN_SFM run COLMAP with selected camera model
    
    % setup paths
    fprintf('> colmap SfM ... ')  
    actual_path = pwd;
    if exist(fullfile(colmap_root_path,'colmap.exe'),'file')        % custom build
        cd(colmap_root_path);
        colmap_executable = fullfile(colmap_root_path,'colmap.exe');
    elseif exist(fullfile(colmap_root_path,'lib'),'dir') &&  exist(fullfile(colmap_root_path,'bin'),'dir') % downloaded binaries
        cd(fullfile(colmap_root_path,'lib','colmap'));                       
        colmap_executable = strrep(fullfile(colmap_root_path,'bin','colmap'),'\','/');
    else
        error('Incorrect colmap_root_path.')
    end                     
    
    % run COLMAP
    [message,cmdout] = system(sprintf('%s mapper --database_path %s --image_path %s --output_path %s &',...
                            colmap_executable,database_path,imgs_dir,sparse_reconstr))
    
    cd(actual_path);
    fprintf('%.2fsec\n',toc)
end

