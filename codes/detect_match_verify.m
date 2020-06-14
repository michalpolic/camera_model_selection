function database_path = detect_match_verify( colmap_root_path, project_dir, cam_model, max_error, voc_tree, results_dir )
%DETECT_MATCH_VERIFY - run colmap

    % test the input directories
    images_dir = fullfile(project_dir, 'images');   
    if ~exist(project_dir,'dir') || ~exist(images_dir,'dir')
        error('Wrong project directory.');
    end
    
    database_path = fullfile(project_dir, 'database.db');
    if ~exist(database_path,'dir') 
        % setup colmap run path
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

        %extract features
        fprintf('> colmap feature extraction ... ')   
        write_status(fullfile(results_dir,'status.txt'), '> colmap feature extraction ... ')
        [~,~] = system(sprintf(['%s feature_extractor --database_path %s ' ...
                                ' --image_path %s --ImageReader.camera_model %s ' ...
                                ' --SiftExtraction.estimate_affine_shape 1 ' ...
                                ' --SiftExtraction.domain_size_pooling 1 --ImageReader.single_camera 1' ...
                                ' --SiftExtraction.max_num_features 2048'],...
                                colmap_executable, database_path, images_dir, cam_model));
        runtime = toc;
        fprintf('%.2fsec\n',runtime)
        write_status(fullfile(results_dir,'status.txt'), sprintf('%.2fsec</br>\n',runtime))

        
        % match features
        fprintf('> colmap matching and verification ... ')
        write_status(fullfile(results_dir,'status.txt'), '> colmap matching and verification ... ')
        [~,~] = system(sprintf(['%s  vocab_tree_matcher --database_path %s ' ...
                                ' --SiftMatching.max_error %d --VocabTreeMatching.vocab_tree_path %s'],...
                                colmap_executable,database_path,max_error,voc_tree));
        runtime = toc;
        fprintf('%.2fsec\n',runtime)
        write_status(fullfile(results_dir,'status.txt'), sprintf('%.2fsec</br>\n',runtime))
        
        cd(actual_path);
    end
end

