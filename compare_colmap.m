% This script compare the run time and scene properties of COLMAP
%
% 1) setup paths, settings
%   1a) copy files to processing directory
% 2) COLMAP reconstruction
%   2a) detect keypoints and find tentative matches
%   2b) create project directories for each camera model 
%   2c) run reconstruction for subset of 15 close images (measure runtime, kill slow processes)
% 3) evaluate quality for all images
%   3a) measure num. of images, points, observations
%   3b) if GT exist, evaluate the camera centers distances
%
% 4) run reconstruction for all assumed N_imgs (measure runtime)
%   4a) init folders, init database
%   4b) run SfM
% 5) evaluate quality for N_imgs
%   5a) measure num. of images, points, observations
%   5b) compute ACC
%       - compute sub-reconstructions for each reproj. error
%		- evaluate ACC

% clear all; close all;
% 
% % testing setup 
queue_dir = '/home/michal/CMS/uploads/test01';

%% 1) setup paths, settings
setting = struct();     % settings
addpath('/home/michal/usfm.github.io/build/src');
javaaddpath('/home/michal/sqlite-jdbc-3.8.7.jar');
colmap_prexif = '/home/colmap/install';
setting.voc_tree = '/home/michal/vocab_tree_flickr100K_words32K.bin';
setting.use_gpu = false;    % cannot use GPU in VM VirtualBox
setting.num_threads = 4;    % number of thread should be smaller or equal available threads

init_env_server;        % load paths 
write_status(fullfile(results_dir,'status.txt'), sprintf('Start model evaluation ... </br>\n'))
write_status(fullfile(results_dir,'running.txt'), sprintf('1'),'wt')

setting.reproj_threshold = [0.5 1 1.5 2];
setting.cam_model = 'RADIAL';
setting.cam_models = {'SIMPLE_PINHOLE','SIMPLE_RADIAL','RADIAL','RADIAL3','RADIAL4', ...
                    'RADIAL1_DIVISION1','RADIAL2_DIVISION2','RADIAL3_DIVISION3'};    
                       
% F10e ransac parameters
setting.useF10e = true;
setting.method = getmethod_F10e;
setting.ransac_iters = 1000;
setting.ransac_threshold = 4;
setting.match_threshold = 4;
setting.lmax = 2;
setting.lmin = -10;
setting.use_SPRT = false;
setting.sprt_tM = 200;
setting.sprt_mS = 2.83;
setting.sprt_delta = 0.05;
setting.sprt_epsilon = 0.15;


% 1a) copy files to processing directory
mkdir(fullfile(processing_dir,'images'));
[status,message,messageId] = copyfile(fullfile(queue_dir,'input_imgs'), fullfile(processing_dir,'images'));


%% process
res = struct();        

%% 2) COLMAP reconstruction
% 2a) detect keypoints, find and verify matches
tic;
imgs_dir = fullfile(processing_dir,'images');
database_path = detect_match_verify(colmap_prexif, processing_dir, setting.cam_model, setting.ransac_threshold, setting.voc_tree, results_dir, setting.use_gpu);  
if setting.useF10e
    rdF10e = update_matches_by_F10e(database_path, imgs_dir, setting, results_dir);
end
res.time_relative_pose = toc;


% create directories for all distortion models
for j = 1:length(setting.cam_models)
    write_status(fullfile(results_dir,'status.txt'), sprintf('> init colmap project for %s</br>\n',setting.cam_models{j}))
    
    % project
    project_dir = fullfile(processing_dir, setting.cam_models{j});

    % 2a) create project directories for each camera model 
    setting.cam_model = setting.cam_models{j};
    [reconstr_database, sparse_reconstr] = init_project(project_dir, database_path, rdF10e, setting);
end
write_status(fullfile(results_dir,'status.txt'), newline) 


% run recosntruction for all camera models
tic;
cmdout = cell(length(setting.cam_models),1);
actual_path = pwd;
if exist(fullfile(colmap_prexif,'lib','colmap'))
    cd(fullfile(colmap_prexif,'lib','colmap')); 
    colmap_executable = strrep(fullfile(colmap_prexif,'bin','colmap'),'\','/');
else
    cd(colmap_prexif); 
    colmap_executable = strrep(fullfile(colmap_prexif,'colmap'),'\','/');
end
for j = 1:length(setting.cam_models)
    fprintf('SfM for dataset: %s, model: %s\n',datset_name, setting.cam_models{j})
    write_status(fullfile(results_dir,'status.txt'), sprintf('> run colmap SfM for %s</br>\n',setting.cam_models{j}))
    project_dir = fullfile(processing_dir, setting.cam_models{j});

    % 2b) run reconstruction for all images (measure runtime)
    [~,cmdout{j}] = system(sprintf('%s mapper --database_path %s --image_path %s --output_path %s &',...
            colmap_executable, fullfile(project_dir,'database.db'), imgs_dir, fullfile(project_dir,'sparse')));
end
cd(actual_path);


% wait for results 
T1 = 120;      % 2 min
alpha = 5;     % stop if (time > alpha * T1) 
running_process = true(length(setting.cam_models),1);
while(true)
    % check finished reconstructions
    for j = 1:length(setting.cam_models)
        if length(dir(fullfile(processing_dir, setting.cam_models{j},'sparse'))) > 2
            if running_process(j)
                res.(setting.cam_models{j}).sfm_time = toc;
                if sum(running_process) == length(running_process)      % set the fastest reconstruction time
                    T1 = res.(setting.cam_models{j}).sfm_time;
                end
                running_process(j) = false;
                fprintf('Finished SfM for model: %s \n', setting.cam_models{j}) 
                write_status(fullfile(results_dir,'status.txt'), sprintf('> finished SfM for %s</br>\n',setting.cam_models{j}))
            end 
        end
    end
    if toc > alpha * T1
        break;
    end
    pause(0.01);
end 

% end slow processes 
for j = 1:length(setting.cam_models)
    if running_process(j)
        fprintf('Kill SfM for model: %s \n', setting.cam_models{j}) 
        write_status(fullfile(results_dir,'status.txt'), sprintf('> kill SfM for %s</br>\n',setting.cam_models{j}))
        system(['kill ' cmdout{j}]);
    end
end


%% 3) evaluate quality for all images

% read results if available
scenes = struct();
for j = 1:length(setting.cam_models)
    if isfield(res,setting.cam_models{j})
        write_status(fullfile(results_dir,'status.txt'), sprintf('> eval. quantitative results for %s\n',setting.cam_models{j}))
        
        % evaluate quality
        one_res = res.(setting.cam_models{j});
        [one_res, scene] = eval_quality(one_res, fullfile(processing_dir, setting.cam_models{j},'sparse'), colmap_prexif);
        scenes.(setting.cam_models{j}) = scene;

        % save the statistic for all images
        res.(setting.cam_models{j}) = one_res;
        write_quantitative_results(fullfile(results_dir,'q_results.txt'), setting.cam_models{j}, one_res)
    end
end


%% 4) evaluate ACS
% This script compare ACS of COLMAP recontructions
% 1) setup paths, settings
% 2) load COLMAP reconstruction with "l" images  
% 3) find common parameters of loaded reconstructions
% 4) compute ACS for all thresholds
% 5) save results

% 2) load COLMAP reconstruction
colmap_image_names = struct();
colmap_scenes_nobs = struct();
colmap_image_allIds = struct();
all_images = cell(0);
all_images_count = cell(0);
for j = 1:length(setting.cam_models)
    fprintf('Selecting largest scene, test model: %s\n',setting.cam_models{j})

    % load scene
    if isfield(scenes,setting.cam_models{j})
        scene = scenes.(setting.cam_models{j});

        % get images names
        sv = scene.images.values;
        colmap_scenes_nobs.(setting.cam_models{j}) = res.(setting.cam_models{j}).nobs;
        colmap_image_names.(setting.cam_models{j}) = ...
            cellfun(@(img) strtrim(img.name), sv, 'UniformOutput', false);

        % get set of all image names
        for k = 1:length(colmap_image_names.(setting.cam_models{j}))
            img_name = colmap_image_names.(setting.cam_models{j}){k};
            name_found = -1;
            for l = 1:length(all_images)
                if strcmp(all_images{l},img_name)
                    name_found = l;
                    break;
                end
            end
            if name_found == -1
                all_images{end+1} = img_name;
                all_images_count{end+1} = 1;
            else
                all_images_count{name_found} = all_images_count{name_found} + 1;
            end
        end
    end
end


% count nonempty colmap scenes
nonempty_scenes_count = 0;
for j = 1:length(setting.cam_models)
    if isfield(scenes, setting.cam_models{j})
        nonempty_scenes_count = nonempty_scenes_count + 1;
    end
end

% 3) find common parameters
common_imgs = {all_images{find(cell2mat(all_images_count) == nonempty_scenes_count)}};
if nonempty_scenes_count == 0 || isempty(common_imgs)
    error('There is no overlap between reconstructions.');
end

% select refence reconstruction
reference_scene = [];
max_nobs = 0;
for j = 1:length(setting.cam_models)
    if isfield(colmap_scenes_nobs,setting.cam_models{j})
        if isempty(reference_scene) || max_nobs < colmap_scenes_nobs.(setting.cam_models{j})
            max_nobs = colmap_scenes_nobs.(setting.cam_models{j});
            reference_scene = scenes.(setting.cam_models{j});
        end
    end
end

% select reference camera centers for common images
ref_common_C = [];
ref_c_imgs = reference_scene.images.values;
for j = 1:length(common_imgs)
    for k = 1:size(reference_scene.images,1)
        if strcmp(common_imgs{j}, strtrim(ref_c_imgs{k}.name))
            ref_common_C = [ref_common_C -ref_c_imgs{k}.R'*ref_c_imgs{k}.t];
        end
    end
end

% go over all camera models
for j = 1:length(setting.cam_models)
    if ~isfield(scenes,setting.cam_models{j})
        continue;
    end
    fprintf('Evaluate ACS for model: %s\n',setting.cam_models{j})
    write_status(fullfile(results_dir,'status.txt'), sprintf('> eval. ACS for %s</br>\n',setting.cam_models{j}))
    scene = scenes.(setting.cam_models{j});
    

    % go over all reprojection error thresholds
    for k = 1:length(setting.reproj_threshold)
        fprintf('  > eval max. reproj. err: %.1fpx\n', setting.reproj_threshold(k))
        loc_d = subscene_Se( clone_scene(scene), setting.reproj_threshold(k) );

        % align loc_d with the largest reconstruction
        % a) find common camera centers
        common_C = [];
        c_imgs = loc_d.images.values;
        for l = 1:length(common_imgs)
            for m = 1:size(reference_scene.images,1)
                if strcmp(common_imgs{l}, strtrim(c_imgs{m}.name))
                    common_C = [common_C -c_imgs{m}.R'*c_imgs{m}.t];
                end
            end
        end
        % b) find transformation
        [~,~,tr] = procrustes(ref_common_C', common_C','Reflection',false);
%         Z = tr.b * tr.T' * common_C + tr.c';
        s = tr.b;
        R = tr.T' * det(tr.T'); 
        t = tr.c(1,:)';
        % c) apply transformation to subscene
        c_pts = loc_d.points3D.values;
        for l = 1:size(c_imgs,2)
            C = - c_imgs{l}.R' * c_imgs{l}.t;
            C = s * R * C + t;
            c_imgs{l}.R = c_imgs{l}.R * R';
            c_imgs{l}.q = r2q(c_imgs{l}.R)';
            c_imgs{l}.t = -c_imgs{l}.R * C;
            loc_d.images(c_imgs{l}.image_id) = c_imgs{l};
        end
        for l = 1:size(c_pts,2)
            c_pts{l}.xyz = s * R * c_pts{l}.xyz + t;
            loc_d.points3D(c_pts{l}.point3D_id) = c_pts{l};
        end


        % 3) find common parameters  -> Jacobian has order points
        % in 3D, image params, cam params
        common_params_ids = [];
        pts_offset = 3*size(c_pts,2)+1;
        c_imgs = loc_d.images.values;
        for l = 1:length(common_imgs)
            for m = 1:size(loc_d.images,1)
                if strcmp(common_imgs{l}, strtrim(c_imgs{m}.name))
                    % m-th image
                    common_params_ids = [common_params_ids pts_offset+6*(m-1):(pts_offset+6*m-1)];
                end
            end
        end

        res.(setting.cam_models{j}).(sprintf('ACC_%02d',round(10*setting.reproj_threshold(k)))) = ...
            accuracy_of_pair_ids(loc_d, common_params_ids);
    end
end
       
% write acs results
acs_vals = zeros(length(setting.cam_models), length(setting.reproj_threshold));
for i = 1:length(setting.cam_models)
    for j = 1:length(setting.reproj_threshold)
        if isfield(res,setting.cam_models{i})
            acs_vals(i,j) = res.(setting.cam_models{i}).(sprintf('ACC_%02d',round(10*setting.reproj_threshold(j)))).AC_trace;
        else
            acs_vals(i,j) = nan;
        end
        write_status(fullfile(results_dir,'acs_results.txt'), sprintf('%.15e ',acs_vals(i,j)))
    end
    write_status(fullfile(results_dir,'acs_results.txt'), newline)
end

% write best model by acs
[vals, sel_models] = max(acs_vals);
for j = 1:length(setting.reproj_threshold)
    write_status(fullfile(results_dir,'selected_model.txt'), ...
        sprintf('Selected model for repr. error %.2fpx id %s</br>\n', setting.reproj_threshold(j), setting.cam_models{sel_models(j)}))    
end


% run LACS


write_status(fullfile(results_dir,'running.txt'), sprintf('0'),'wt')





