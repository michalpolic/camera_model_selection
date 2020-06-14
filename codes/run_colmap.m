function [ res, database_path ] = run_colmap( res, project_dir, imgs_dir, sparse_reconstr, setting )
%RUN_COLMAP - run colmap reconstruction
    
    % compute matches
    tic;
    database_path = detect_match_verify(setting.colmap_path, project_dir, ...
                        setting.cam_model, setting.F10_threshold, setting.voc_tree);  
    res.time_relative_pose = toc;

    % use F10e alg. to estimate radial distortion
    if isfield(setting,'useF10e') && setting.useF10e
        update_matches_by_F10e(database_path, project_dir, imgs_dir, setting);
    end
    
    % setup colmap run path
    res = run_sfm(res, database_path, imgs_dir, sparse_reconstr, setting);
end

