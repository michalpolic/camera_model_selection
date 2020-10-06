rng('shuffle');
addpath('/home/policmic/documents/libs/usfm.github.io/build/src');
javaaddpath('/home/policmic/documents/libs/sqlite-jdbc-3.8.7.jar');

if isempty(gcp('nocreate'))
    parpool(setting.num_threads);
end

if exist(fullfile(pwd,'..','common_codes'),'dir')
    addpath(fullfile(pwd,'..','common_codes'));
end
if exist(fullfile(pwd,'codes'),'dir')
    addpath(fullfile(pwd,'codes'));
end
if exist(fullfile(pwd,'external_functions','F10-0.1','matlab'),'dir')
    addpath(fullfile(pwd,'external_functions','F10-0.1','matlab'));
end
if exist(fullfile(pwd,'external_functions','F10-0.1','matlab','util'),'dir')
    addpath(fullfile(pwd,'external_functions','F10-0.1','matlab','util'));
end
if exist(fullfile(pwd,'external_functions','F10-0.1','matlab','vl'),'dir')
    addpath(fullfile(pwd,'external_functions','F10-0.1','matlab','vl'));
end

% absolute server paths
colmap_prexif = '/home/policmic/documents/libs/colmap-install';
if exist(colmap_prexif,'dir')
    addpath(colmap_prexif);
end

% processing dir
[filepath1,datset_name,ext] = fileparts(queue_dir);
[filepath_parent,name,ext] = fileparts(filepath1); 
processing_dir = fullfile(filepath_parent, 'processing', datset_name);
mkdir(processing_dir);

% results dir
results_dir = fullfile(filepath_parent, 'results', datset_name);
mkdir(results_dir);
