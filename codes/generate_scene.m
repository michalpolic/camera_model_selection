function [ scene ] = generate_scene( temp_dataset_dirs, calib_params, setting )
%GENERATE_SCENE Summary of this function goes here
    scene = [];
    tic; fprintf('\nGenerate dataset ... \n')
    while isempty(scene)
        dataset_dir = temp_dataset_dirs{randi(length(temp_dataset_dirs))};
        cam_params = calib_params(randi(length(calib_params)));
        scene = generate_subscene(dataset_dir, cam_params.camera_models.(setting.cam_model), rmfield(setting,'missmatches'));
        if ~isempty(scene)
            fprintf('> adjust keypoints ...  ')
            scene = adjust_keypoints( scene, cam_params, setting );
            fprintf('> add missmatches ...  ')
            missmatches = rand(1) * setting.missmatches(2) - setting.missmatches(1);
            if missmatches > 0
                scene = add_missmatches( scene, missmatches );
            end
            fprintf('\nGenerate dataset ...  %.2fsec\n',toc)
        end
    end    
end

