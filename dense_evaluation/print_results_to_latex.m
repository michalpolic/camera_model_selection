clc; clear; close all;
load('tmp_results.mat');

scene_names = fields(results);
for i = 1:size(scene_names,1)
    cam_models = fields(results.(scene_names{i}));
    if i == 1
        fprintf('F1-score');
        for j = 1:size(cam_models,1)
            fprintf('& %s ',strrep(cam_models{j},'_','\_'));
        end
        fprintf('\\\\ \n');
        fprintf('\\hline \n');
    end
    
    %find best res.
    xxx = cell(4,1);
    for j = 1:size(cam_models,1)
        loc_res = results.(scene_names{i}).(cam_models{j});
        if ~isempty(loc_res.f1_scores)
            for k = 1:4
                xxx{k} = [xxx{k} loc_res.f1_scores(k)];
            end
        end
    end
    for k = 1:4
        xxx{k} = sort(xxx{k},'descend');
    end
    
    fprintf('%s ',strrep(scene_names{i},'_','\_'));
    for j = 1:size(cam_models,1)
        loc_res = results.(scene_names{i}).(cam_models{j});
        if isempty(loc_res.f1_scores)
            fprintf('& -; -; -; -; ');
        else
            fprintf('& %s\\%%; %s\\%%; %s\\%%; %s\\%% ',...
                highlight_b12(loc_res.f1_scores(1), xxx{1}), ...
                 highlight_b12(loc_res.f1_scores(2), xxx{2}), ...
                  highlight_b12(loc_res.f1_scores(3), xxx{3}), ...
                   highlight_b12(loc_res.f1_scores(4), xxx{4}));
        end
    end
    fprintf('\\\\ \n');
end



fprintf('\n\n\n');
for i = 1:size(scene_names,1)
    cam_models = fields(results.(scene_names{i}));
    if i == 1
        fprintf('completenesses');
        for j = 1:size(cam_models,1)
            fprintf('& %s ',strrep(cam_models{j},'_','\_'));
        end
        fprintf('\\\\ \n');
        fprintf('\\hline \n');
    end
    
    %find best res.
    xxx = cell(4,1);
    for j = 1:size(cam_models,1)
        loc_res = results.(scene_names{i}).(cam_models{j});
        if ~isempty(loc_res.f1_scores)
            for k = 1:4
                xxx{k} = [xxx{k} loc_res.completenesses(k)];
            end
        end
    end
    for k = 1:4
        xxx{k} = sort(xxx{k},'descend');
    end
    
    fprintf('%s ',strrep(scene_names{i},'_','\_'));
    for j = 1:size(cam_models,1)
        loc_res = results.(scene_names{i}).(cam_models{j});
        if isempty(loc_res.f1_scores)
            fprintf('& -; -; -; -; ');
        else
            fprintf('& %s\\%%; %s\\%%; %s\\%%; %s\\%% ',...
                highlight_b12(loc_res.completenesses(1), xxx{1}), ...
                 highlight_b12(loc_res.completenesses(2), xxx{2}), ...
                  highlight_b12(loc_res.completenesses(3), xxx{3}), ...
                   highlight_b12(loc_res.completenesses(4), xxx{4}));
        end
    end
    fprintf('\\\\ \n');
end



fprintf('\n\n\n');
for i = 1:size(scene_names,1)
    cam_models = fields(results.(scene_names{i}));
    if i == 1
        fprintf('accuracies');
        for j = 1:size(cam_models,1)
            fprintf('& %s ',strrep(cam_models{j},'_','\_'));
        end
        fprintf('\\\\ \n');
        fprintf('\\hline \n');
    end
    
    %find best res.
    xxx = cell(4,1);
    for j = 1:size(cam_models,1)
        loc_res = results.(scene_names{i}).(cam_models{j});
        if ~isempty(loc_res.f1_scores)
            for k = 1:4
                xxx{k} = [xxx{k} loc_res.accuracies(k)];
            end
        end
    end
    for k = 1:4
        xxx{k} = sort(xxx{k},'descend');
    end
    
    
    fprintf('%s ',strrep(scene_names{i},'_','\_'));
    for j = 1:size(cam_models,1)
        loc_res = results.(scene_names{i}).(cam_models{j});
        if isempty(loc_res.f1_scores)
            fprintf('& -; -; -; -; ');
        else
            fprintf('& %s\\%%; %s\\%%; %s\\%%; %s\\%% ',...
                highlight_b12(loc_res.accuracies(1), xxx{1}), ...
                 highlight_b12(loc_res.accuracies(2), xxx{2}), ...
                  highlight_b12(loc_res.accuracies(3), xxx{3}), ...
                   highlight_b12(loc_res.accuracies(4), xxx{4}));
        end
    end
    fprintf('\\\\ \n');
end