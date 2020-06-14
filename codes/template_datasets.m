% teplate datasets
prefix1 = fullfile(dropbox_prexif,'DATASETS');
temp_datset_name = {'courtyard';'delivery_area';'electro';'facade';'kicker';...
    'meadow';'office';'pipes';'playground';'relief';'relief_2';'terrace';'terrains'};
temp_dataset_dirs = cell(length(temp_datset_name),1);
for i = 1:length(temp_datset_name)
    temp_dataset_dirs{i} = fullfile(prefix1,temp_datset_name{i},'dslr_calibration_jpg');
end
temp_images_dir = cell(length(temp_datset_name),1);
for i = 1:length(temp_images_dir)
    temp_images_dir{i} = fullfile(prefix1,temp_datset_name{i},'images','dslr_images');
end

% camera parameters samples
temp_camera_sample_params = fullfile(gsuite_prefix,'camera_model_samples');