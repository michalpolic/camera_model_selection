function [ d ] = optimize_scene( d, setting, sigma )
%OPTIMISE_SCENE - run the optimization of reprojection error 

    % settings
    if nargin < 2
        setting = struct();
        setting.alg = 'JACOBIAN_ESTIMATOR';
        setting.in_cov = 'UNIT';
        setting.run_opt = 1;
        setting.run_opt_radial = 0;
    end

    % standard deviation of residuals
    if nargin < 3
        sigma = 1;
    end
    
    % run optimization
    d = add_obs_variance(d, sigma^2);
    [~, cell_d] = usfm_mex(setting, d.cameras.values, d.images.values, d.points3D.values);
    d_opt = sceneCell2Map( cell_d );         % save scene after BA
    d = normalize_dataset(d_opt);
end

