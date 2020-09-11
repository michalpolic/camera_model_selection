function [ test_res ] = generate_press_cnn_samples( scene, residuals, setting )
%GENERATE_PRESS_CNN_SAMPLES - generate samples for cnn learning
% PROCESS
% 1) compose graph obs-pts
% 2) optimze scene w.r.t. tested camera models
% 3) prepare mexpres matrices
% 4) select subset of observations for learning
%   4a) gather neighbouring observations 
%   4b) generate tests / not used / training sets 
%   4c) evaluate mexpress on the subsets
% 5) save sample 

    % 1) compose graph obs-pts
    [G, img_start_ids] = compose_obs_pts_graph( scene );
        
    test_res = struct();
    for model_id = 1:length(setting.cam_models)
        
        % 2) optimize scene for each camera model
        d = clone_scene(scene);
        d.cameras = update_cam_models(d.cameras, setting.cam_models{model_id});
        d = add_obs_variance(d, setting);
        [~, cell_d_lo] = usfm_mex(setting.opt, d.cameras.values, d.images.values, d.points3D.values);
        d = sceneCell2Map( cell_d_lo ); 

        % 3) prepare mexpres matrices
        precomputed = prepare_mexpress( d, residuals, setting );
        precomputed.residuals = residuals;

        % 4) select subset of observations for learning
        res = cell(0);
        n = 1;
        tried_n = 1;
        while (n <= setting.press_gen_samples && tried_n < 100)
            tried_n = tried_n + 1;

            % 4) select randomly an observation if the list of observations
            % does not exist yet
            if n <= size(res,2)
                img_obs_id = res{n}.img_obs_id;
                nused_rows = res{n}.rows;
            else
                img_obs_id = G.obs(randi(length(G.obs),1));
            
                % 4a) gather neighbouring observations 
                c_imgs = d.images.values();
                img = c_imgs{img_obs_id(3)};
                obs = img.xys(img_obs_id(1),:)';
                D = sqrt(sum((img.xys' - obs).^2));
                N = min([setting.press_max_neighgours length(D)]);
                [nobs_dist, nobs_ids] = sort(D); 
                nobs_dist = nobs_dist(1:N);
                tmp_ids = img_start_ids(img_obs_id(3)):img_start_ids(img_obs_id(3))+length(D)-1;
                gnobs_ids = tmp_ids(nobs_ids(1:N));

                % 4b) generate tests / not used / training sets 
                radius = [0.01:0.01:1] * max(nobs_dist);
                nused_subsets = cell(length(radius),1);
                test_ids = zeros(length(radius),1);
                stop_test = false;
                for j = 1:length(radius)    
                    f = nobs_dist < radius(j);
                    nused_subsets{j} = remove_related_obs(G, gnobs_ids(f), length(c_imgs));

                    % we are too far and some image colapse, do not test further subsets
                    if isempty(nused_subsets{j})
                        if j == 1
                            stop_test = true;
                        else
                            nused_subsets = nused_subsets(1:j-1);
                            test_ids = test_ids(1:j-1);
                        end
                        break;
                    else
                        test_ids(j) = find(nused_subsets{j} == img_obs_id(2));
                    end
                end

                % if we remve the smalest radius of points scene is incositent,
                % i.e., try another observation
                if stop_test
                    continue;
                end

                % rewrite the ids of observations into row ids of J
                nused_rows = cell(length(nused_subsets),1);
                for j = 1:length(nused_subsets)
                    row_ids = [2*nused_subsets{j}'-1; 2*nused_subsets{j}'];
                    nused_rows{j} = row_ids(:);
                end
            end

            % 4c) evaluate mexpress on the subsets
            [~, ~, sse_obs] = mexpress( d, nused_rows, setting, precomputed );
            est_err = zeros(1,length(sse_obs));
            for j = 1:length(sse_obs) 
                r = sqrt(sum(reshape(sse_obs{j},2,length(sse_obs{j})/2).^2));
                est_err(j) = r(test_ids(j));
            end
            

            % 5) save sample  
            % compres points w.r.t. their radius
            body_radius = zeros(2,length(nused_subsets{end}));
            body_radius(2,:) = nused_subsets{end}';
            for j = length(nused_subsets):-1:1
                [~,IA,~] = intersect(body_radius(2,:),nused_subsets{j}); 
                body_radius(1,IA) = j;
            end
            [~,ids_body_radius] = sort(body_radius(1,:));
            body_radius = body_radius(:,ids_body_radius);
            
            % save
            res{n} = struct();
            res{n}.bod = img_obs_id(2);
            res{n}.body_radius = body_radius;
            res{n}.residuals = residuals;
            %res{n}.rows = nused_rows;
            res{n}.est_err = est_err;
            res{n}.nobs_dist = nobs_dist;
            res{n}.radius = radius(1:length(est_err));
            n = n + 1;
        end 

        % 6) compose global table 
        test_res.(setting.cam_models{model_id}) = res;
    end
    
    % 6) compose global table 
    out = cell(setting.press_gen_samples,1);
    for j = 1:setting.press_gen_samples
        for i = 1:length(setting.cam_models)
            one_test = test_res.(setting.cam_models{i}){j};
            if isempty(out{j})
                out{j} = nan(length(setting.cam_models),length(one_test.radius));
            end
            out{j}(i,1:length(one_test.est_err)) = one_test.est_err;
        end
    end
    
    % 7) find which model whould press select
    correct_model = find(cellfun(@(model) strcmp(model,setting.cam_model), setting.cam_models));
%     for j = 1:setting.press_gen_samples
%         one_test = out{j};
%         up_to = find(isnan(sum(one_test)));
%         if ~isempty(up_to)
%             one_test = one_test(:,1:min(up_to)-1);
%         end
%         [~, sel_model] = sort(one_test);
%         sel_corr_model = find(sel_model(1,:) == correct_model);
%             
%         one_test = one_test(:,sel_corr_model);
%         [sel_vals, sel_model] = sort(one_test);
%         [~,id] = max(sel_vals(2,:) - sel_vals(1,:));
%     end
    
    test_res.scene = scene;
    test_res.eval = struct();
    test_res.eval.correct_model = correct_model;
    test_res.eval.out = out;
end

