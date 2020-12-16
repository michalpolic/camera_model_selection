% This script calculate the dense reconstruction by colmap for list of
% scenes and list of camera models. Further, the dense models are compared
% with groud thruth from ETH3D datasets. 
%
% 1) Specify: paths to COLMAP, list of scenes, camera models, other params
% 2) Run dense reconstruction by COLMAP
% 3) Run the comparision script from ETH3D datasets 

clear;
close all;


%% 1) Specify: paths to COLMAP, list of scenes, camera models, other params
setting = struct();
setting.use_correct_camera_poses = true;

setting.scenes = struct();
setting.scenes.names = {'courtyard'};%,'delivery_area','electro','facade','kicker', ...
   % 'meadow','office','pipes','playground','relief','relief_2','terrace','terrains'};

setting.cam_models = {'SIMPLE_PINHOLE','SIMPLE_RADIAL','RADIAL','RADIAL3','RADIAL4', ...
                    'RADIAL1_DIVISION1','RADIAL2_DIVISION2','RADIAL3_DIVISION3'}; 
                
% paths                
if exist('e:/policmic/Dropbox','dir')       % IMPACT PC
    setting.correct_camera_poses_dir = 'e:/policmic/Dropbox/DATASETS_GT';
    setting.colmap_path = 'e:/policmic/software/colmap/build/src/exe/Release';
    setting.colmap_exe = fullfile(setting.colmap_path,'colmap.exe');
    setting.scenes.root_path = 'e:/policmic/Dropbox/DATASETS';
    setting.compare_dir = 'e:/policmic/Dropbox/Pomoc/CameraModelSelectionETH3D_2';
    setting.compare_bin = 'e:/policmic/Dropbox/Pomoc/multi_view_evaluation_windows/ETH3DMultiViewEvaluation.exe';
    setting.compare_dense_gt = 'e:/policmic/Dropbox/Pomoc/GT';
elseif exist('d:/Dropbox','dir')            % Local PC
    setting.correct_camera_poses_dir = 'd:/Dropbox/DATASETS_GT';
    setting.colmap_path = 'd:/Dropbox/Software/colmap/build/src/exe/Release';
    setting.colmap_exe = fullfile(setting.colmap_path,'colmap.exe');
    setting.scenes.root_path = 'd:/Dropbox/DATASETS';
    setting.compare_dir = 'd:/Dropbox/Pomoc/CameraModelSelectionETH3D_2';
    setting.compare_bin = 'd:/Help/ETH3DMultiViewEvaluation/ETH3DMultiViewEvaluation.exe';
    setting.compare_dense_gt = 'd:/Help/ETH3DMultiViewEvaluation/GT';
else                                        % unknown PC 
    error('Setup the paths.');
end

            


%% 2) Run dense reconstruction by COLMAP
for scene_id = 1:size(setting.scenes.names,2)
    
    % oad the correct camera poses
    if setting.use_correct_camera_poses
        correct_scene_path = fullfile(setting.correct_camera_poses_dir,...
                setting.scenes.names{scene_id}, 'dslr_calibration_jpg');
    	cameras_correct = read_model(correct_scene_path);
    end
 
    for cam_model_id = 1:size(setting.cam_models,2)
        % path to dataset
        fprintf('\n\nEvaluating %s -> %s\n',setting.scenes.names{scene_id}, setting.cam_models{cam_model_id});
        scene_path = fullfile(setting.scenes.root_path,setting.scenes.names{scene_id},...
        	setting.cam_models{cam_model_id}); 
        if setting.use_correct_camera_poses
            sparse_scene_path = fullfile(scene_path,'sparse_mixed','0');
        else
            sparse_scene_path = fullfile(scene_path,'sparse','0');
        end
        
        if ~exist(fullfile(scene_path,'sparse','0'),'dir')
            continue;
        end
        
        % replace the camera parameters of correct scene
        if setting.use_correct_camera_poses
        	cameras = read_model(fullfile(scene_path, 'sparse', '0'));
            cam = cameras(1);
            cell_cameras_correct = cameras_correct.values;
            for i = 1:size(cameras_correct,2)
                cam_correct = cell_cameras_correct{i};
                cam_correct.model = cam.model;
                cam_correct.width = cam.width;
                cam_correct.height = cam.height;
                cam_correct.params = cam.params;
                cameras_correct(cam_correct.camera_id) = cam_correct;
            end
            mkdir(fullfile(scene_path, 'sparse_mixed','0'));
            write_cameras(fullfile(sparse_scene_path,'cameras.txt'),cameras_correct);
            copyfile(fullfile(correct_scene_path,'images.txt'),fullfile(sparse_scene_path,'images.txt'));
            copyfile(fullfile(correct_scene_path,'points3D.txt'),fullfile(sparse_scene_path,'points3D.txt'));
            if ~exist(fullfile(scene_path,'images'),'dir')
                copyfile(fullfile(setting.correct_camera_poses_dir,setting.scenes.names{scene_id},'images'),...
                    fullfile(scene_path,'images'));
            end
        end
        
        % dense reconstruction
        if ~exist(fullfile(scene_path,'dense','fused.ply'),'file')
            dense_scene_path = fullfile(scene_path,'dense');

            mkdir(dense_scene_path);
            system(sprintf(['%s image_undistorter '...
                '--image_path %s/images ',...
                '--input_path %s ' ...
                '--output_path %s ' ...
                '--max_image_size 2000 ' ...
                '--output_type COLMAP'],...
                setting.colmap_exe, scene_path, sparse_scene_path, dense_scene_path));

            system(sprintf(['%s patch_match_stereo '...
                '--workspace_path %s ' ...
                '--workspace_format COLMAP ' ...
                '--PatchMatchStereo.max_image_size 2000 ' ...
                '--PatchMatchStereo.geom_consistency true'],...
                setting.colmap_exe, dense_scene_path));

            system(sprintf(['%s stereo_fusion '...
                '--workspace_path %s ' ...
                '--workspace_format COLMAP ' ...
                '--input_type geometric '...
                '--output_path %s/fused.ply'],...
                setting.colmap_exe, dense_scene_path, dense_scene_path));
        end
    end
end

%% 3) Run the comparision script from ETH3D datasets
results = struct();
for scene_id = 1:size(setting.scenes.names,2)
    for cam_model_id = 1:size(setting.cam_models,2)
        
        % prepare dense reconstructions to dir for evaluation
        dense_scene_path = fullfile(setting.scenes.root_path,setting.scenes.names{scene_id},...
        	setting.cam_models{cam_model_id},'dense','fused.ply'); 
%         setting.compare_dir  = fullfile(setting.compare_dir, setting.cam_models{cam_model_id},'high_res_multi_view');
%         if ~exist(setting.compare_dir ,'dir')
%             mkdir(setting.compare_dir );
%         end
%         if exist(dense_scene_path,'file')
%             fprintf('Copy dense reconstruction: %s %s',setting.scenes.names{scene_id}, setting.cam_models{cam_model_id});
%             if ~exist(setting.compare_dir,'dir')
%                mkdir(setting.compare_dir); 
%             end
%             copyfile(dense_scene_path,fullfile(setting.compare_dir,[setting.scenes.names{scene_id} ...
%                 '_'  setting.cam_models{cam_model_id} '.ply']));
%             fileID = fopen(fullfile(setting.compare_dir ,[setting.scenes.names{scene_id} '.txt']),'w');
%             fprintf(fileID,'runtime 999\n');
%             fclose(fileID);
%             fprintf('... [done]\n');
%         end
        
        % run the evaluation binaries
        fprintf('Evaluate statistics: %s %s',setting.scenes.names{scene_id}, setting.cam_models{cam_model_id});
        [~, stdout] = system(sprintf('%s --tolerances 0.02,0.05,0.1,0.2 --reconstruction_ply_path %s --ground_truth_mlp_path %s',...
            setting.compare_bin, fullfile(setting.compare_dir,[setting.scenes.names{scene_id} '_'  setting.cam_models{cam_model_id} '.ply']),...
            fullfile(setting.compare_dense_gt,setting.scenes.names{scene_id},'dslr_scan_eval','scan_alignment.mlp')));
        fprintf('... [done]\n');
        
        % parse and save results
        if ~isfield(results, setting.scenes.names{scene_id})
            results.(setting.scenes.names{scene_id}) = struct();
        end
        if ~isfield(results.(setting.scenes.names{scene_id}), setting.cam_models{cam_model_id})
            results.(setting.scenes.names{scene_id}).(setting.cam_models{cam_model_id}) = struct();
        end
        loc_res = struct();
        loc_res.tolerances = str2num(stdout(strfind(stdout, 'Tolerances:')+12:strfind(stdout, 'Completenesses:')-1));
        loc_res.completenesses = str2num(stdout(strfind(stdout, 'Completenesses:')+15:strfind(stdout, 'Accuracies:')-1));
        loc_res.accuracies = str2num(stdout(strfind(stdout, 'Accuracies:')+11:strfind(stdout, 'F1-scores:')-1));
        loc_res.f1_scores = str2num(stdout(strfind(stdout, 'F1-scores:')+10:end));
        results.(setting.scenes.names{scene_id}).(setting.cam_models{cam_model_id}) = loc_res;
    end
end

% save('tmp_results.mat','results');

