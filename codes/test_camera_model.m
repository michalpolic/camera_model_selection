function [ out, err2 ] = test_camera_model( scene, test_alg, sigma, err2 )
%TEST_CAMERAS_FOR_SCENE - test the camera model using selected algorithm
    
    if nargin < 4 || isempty(err2)
        err2 = reproj_err2(scene);
    end
    k = num_of_scene_params(scene);
    max_k = num_of_scene_params(scene, max_num_cam_params(scene));
    N = 2*num_of_obs(scene);
    est_sigma2 = sum(err2) / (N - max_k);
    est_sigma2_model = sum(err2) / (N - k);
    sigma2 = sigma * sigma;
    
    % 'AIC','MDL','BIC','SSD','CAIC': V. L. Orekhov - A Full Scale Camera Calibration Technique with Automatic Model Selection – Extension and Validation
    % 'G_AIC','G_MDL': K. Kanatani - Uncertainty Modeling and Model Selection for Geometric Inference 
    switch test_alg
        case 'REPROJ_ERR'
            out = sum(sqrt(err2)) / size(err2,2);
        case 'N_P3D'
            out = size(scene.points3D,1);
        case 'COV_VF'       % VARIANCE_FACTOR is computed from residuals and number of scene parameters
            out = usfm_mex(struct('alg','NBUP','in_cov','VARIANCE_FACTOR','run_opt',1), scene.cameras.values, scene.images.values, scene.points3D.values);
        case 'COV_ST'       % STRUCTURE_TENSOR is computed from image gradients
            scene = add_obs_variance(scene, sigma2);    % to be able use: in_cov = STRUCTURE_TENSOR
            out = usfm_mex(struct('alg','NBUP','in_cov','STRUCTURE_TENSOR','run_opt',1), scene.cameras.values, scene.images.values, scene.points3D.values);
        case 'AIC'
            out = sum(err2)/est_sigma2 + 2*k;
        case 'MDL'
            out = sum(err2)/est_sigma2 + 0.5*k*log(2*N);
        case 'BIC'
            out = sum(err2)/est_sigma2 + k*log(2*N);    % [A. Gelman et all, Understanding predictive information criteria for Bazeisian models]
        case 'SSD'
            out = sum(err2)/est_sigma2 + k*log((2*N+2)/24);
        case 'CAIC'
            out = sum(err2)/est_sigma2 + k*(log(2*N)+1);
        case 'G_AIC'        % we need add variance of the input, i.e., explore the image observations (we use known sigma instead) 
            out = sum(err2)/est_sigma2_model + 2*(N+k)*est_sigma2_model;    
        case 'G_MDL'        % we need add variance of the input, i.e., explore the image observations (we use known sigma instead) 
            out = sum(err2)/est_sigma2_model - (N+k)*est_sigma2_model*log(est_sigma2_model);
        otherwise
            error('Unknown camera model test.');
    end  
end

% Compute reprojection error 
function repr_err2 = reproj_err2(scene)
    c_imgs = scene.images.values;
    u_obs = cell(1,size(c_imgs,2));
    u_proj = cell(1,size(c_imgs,2));
    for i = 1:size(c_imgs,2)
        img = c_imgs{i};
        cam = scene.cameras(img.camera_id);  
        reconst_filter = img.point3D_ids ~= -1;
        u_obs{i} = img.xys(reconst_filter,:)';
        pt3D_ids = img.point3D_ids(reconst_filter);
        X = cell2mat(arrayfun(@(pt_id)scene.points3D(pt_id).xyz,pt3D_ids,'UniformOutput', false)');
        u_proj{i} = proj( cam, img, X );
    end
    repr_err2 = (sum((cell2mat(u_obs) - cell2mat(u_proj)).^2));
end
