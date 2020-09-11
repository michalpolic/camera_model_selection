function fig = plot_colmap_scene( colmap_scene, cov )
    tmp_cams = colmap_scene.cameras.values;
    tic; fprintf('%s plot ...',tmp_cams{1}.model)
    
    % if the second param. is empty but exists, use the cov from scene
    if nargin > 1 && isempty(cov) && isfield(colmap_scene,'cov')
        cov = colmap_scene.cov;
    end
    
    
    fig = figure(); 
    hold on; axis equal; grid on; title(sprintf('Cam: %s',strrep(tmp_cams{1}.model,'_','\_')));
    xlabel('x'); ylabel('y'); zlabel('z'); 
    
    % points 
    c_pts = colmap_scene.points3D.values;
    X = cell2mat(arrayfun(@(i)c_pts{i}.xyz,1:size(c_pts,2),'UniformOutput',false));
    plot3(X(1,:),X(2,:),X(3,:),'k.');
    if exist('cov','var')
        for i = 1:size(c_pts,2)
            h = plotCov(10000*cov.points{i}, X(:,i), false, [0 0 0] ); 
            h.FaceAlpha = 0.2;
        end
    end
    
    % cameras
    c_imgs = colmap_scene.images.values;
    C = cell2mat(arrayfun(@(i)-c_imgs{i}.R' * c_imgs{i}.t, 1:size(c_imgs,2),'UniformOutput',false));
    plot3(C(1,:),C(2,:),C(3,:),'b.','MarkerSize',15);
    if exist('cov','var')
        for i = 1:size(c_imgs,2)
            cov_img = cov.images{i};
            h = plotCov(10000*cov_img(4:6,4:6), C(:,i), false, [0 0 1] ); 
            h.FaceAlpha = 0.2;
        end
    end
    fprintf('%.2fsec\n',toc)
end

