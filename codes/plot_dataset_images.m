function plot_dataset_images( colmap_scene, title_string, save_prefix, Nimgs )
%PLOT_DATASET_IMAGES - plot the images in dataset

    if ~exist('Nimgs','var')    
        Nimgs = size(colmap_scene.images,1);
    end
    
    c_imgs = colmap_scene.images.values;
    for i = 1:Nimgs
        img = c_imgs{i};
        cam = colmap_scene.cameras(img.camera_id);
        u_obs = img.xys';
        reconst_filter = img.point3D_ids ~= -1;
        pt3D_ids = img.point3D_ids(reconst_filter);
        pts = arrayfun(@(pt_id)colmap_scene.points3D(pt_id).xyz,pt3D_ids,'UniformOutput', false);
        if ( size(pts,1) ~= 1 )
            pts = pts';
        end
        X = cell2mat(pts);
        u_proj = proj( cam, img, X );
        
        % plot image 
        if exist(img.name,'file')
            imshow(imread(img.name));
        end
        subfig(3,4,mod(i,12)+1,gcf); hold on; axis equal; axis ij; grid on;
        xlabel('x'); ylabel('y'); %axis([0 cam.width 0 cam.height]);
        if isfield(img,'inliers')
            plot( u_obs(1,img.inliers==1), u_obs(2,img.inliers==1), 'go');
            plot( u_obs(1,img.inliers==0), u_obs(2,img.inliers==0), 'ro');
        else 
            plot( u_obs(1,:), u_obs(2,:), 'go');
        end
        plot( u_proj(1,:), u_proj(2,:), 'r.');
        u_rec = u_obs(:,reconst_filter);
%         err_direction = u_proj - u_rec;
%         scale = 100;
        for j = 1:size(u_rec,2)
            plot( [u_rec(1,j) u_proj(1,j)], [u_rec(2,j) u_proj(2,j)], 'b-'); 
%             quiver( u_rec(1,j), u_rec(2,j), scale*err_direction(1,j), scale*err_direction(2,j),'r-');
        end 
        
        % plot image border 
        plot([0 cam.width cam.width 0 0], [0 0 cam.height cam.height 0], '-', 'Color', [.5 .5 .5]);
        
        
        % setup title
        if exist('title_string','var') && ~isempty(title_string)
            title(sprintf('%s, img: %d [%s]',title_string,i,strrep(cam.model,'_','\_'))); xlabel('x'); ylabel('y');
        else
            title(sprintf('Img: %d [%s]',img.image_id,strrep(cam.model,'_','\_'))); xlabel('x'); ylabel('y');
        end
        
        % save
        if exist('save_prefix','var') && ~isempty(save_prefix)
            saveas(gcf,sprintf('%s_img_%d.jpg',save_prefix,i));
        end
    end

end

