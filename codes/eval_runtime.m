function [res, new_sparse_reconstr] = eval_runtime(res, project_dir, setting)
%EVAL_RUNTIME - compute the runtime, the reconstruction directory, copy
%resuts to standard path

    % create dir for sparse reconstruction with 15images
    new_sparse_reconstr = fullfile(project_dir,sprintf('sparse_%02d',setting.nimgs));
    
    if ~exist(new_sparse_reconstr,'dir')
        mkdir(new_sparse_reconstr);

        % read dirs
        directories = dir(setting.snapshot_path);
        
        % look into the directories -> find model
        timestamsps = [];
        rec_dir = '';
        rec_dir_id = [];
        for i = 1:length(directories)
            if ~strcmp(directories(i).name,'.') && ~strcmp(directories(i).name,'..')
                timestamsps = [timestamsps str2num(directories(i).name)];
                sfm_snapshot_files = dir(fullfile(directories(i).folder,directories(i).name));
                if length(sfm_snapshot_files) > 2
                    rec_dir_id = [rec_dir_id 1];
                    rec_dir = fullfile(directories(i).folder,directories(i).name);
                else
                    rec_dir_id = [rec_dir_id 0];
                end
            end
        end
        
        if sum(rec_dir_id) > 0
            % copy the reconstruction
            res.time_sfm = 10^(-3) * (max(timestamsps) - min(timestamsps));
            pause(0.5);
            copyfile(fullfile(rec_dir,'*'),fullfile(new_sparse_reconstr,'0'));
        else 
            res.failed = true;
        end
    end
end

