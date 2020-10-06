function plot_reprojection_error( colmap_scene, title_string, save_file )
%PLOT_REPROJECTION_ERROR - plot reprojection errors for colmap scene
      
    c_imgs = colmap_scene.images.values;
    u_obs = cell(1,size(c_imgs,2));
    u_proj = cell(1,size(c_imgs,2));
    repr_err = cell(1,size(c_imgs,2));
    images_legend = cell(1,size(c_imgs,2));
    col = getColors(size(c_imgs,2));
    
%     subfig(3,3,1); hold on; grid on; xlabel('sample'); 
%     ylabel('reprojection error [px]'); 
    legend_titles = cell(1,size(c_imgs,2));
%     err_offset = 1;
    for i = 1:size(c_imgs,2)
        img = c_imgs{i};
        cam = colmap_scene.cameras(img.camera_id);
        
        reconst_filter = img.point3D_ids ~= -1;
        u_obs{i} = img.xys(reconst_filter,:)';
        pt3D_ids = img.point3D_ids(reconst_filter);
        XX = arrayfun(@(pt_id)colmap_scene.points3D(pt_id).xyz,pt3D_ids,'UniformOutput', false);
        if size(XX,1) ~= 1
            XX = XX';
        end
        X = cell2mat(XX);
        u_proj{i} = proj( cam, img, X );
        
        repr_err{i} = sqrt(sum((u_obs{i} - u_proj{i}).^2));
        images_legend{i} = sprintf('cam: %d, img: %d, cam:%s',cam.camera_id, img.image_id, lower(strrep(cam.model,'_','\_')));
%         legend_titles{i} = sprintf('Img:%d,Cam:%d,%s',img.image_id,cam.camera_id,strrep(cam.model,'_','\_'));
%         plot(err_offset:(err_offset+size(u_obs{i},2)-1),sort(repr_err{i}),'.','Color',col{i},'MarkerSize',10);
%         err_offset = err_offset + size(u_obs{i},2);
    end
    
%     repr_err = sqrt(sum((cell2mat(u_obs) - cell2mat(u_proj)).^2));
%     title(sprintf('Reprojection error [mean: %.2f, std: %.2f]',mean(repr_err), std(repr_err)));
%     legend(legend_titles);
    
    cols = getColors(size(c_imgs,2));   %max(cell2mat(repr_err))
    mboxplot(repr_err, '1', [0 3], '#image', 'reprojection error [px]', images_legend, cols, 1);
    if exist('title_string','var')
        t = title(sprintf('%s, reproj. err. [mean: %.2f, std: %.2f]',title_string, mean(cell2mat(repr_err)), std(cell2mat(repr_err))));
        t.FontSize = 10;
    end
    if exist('save_file','var')
        saveas(gcf,save_file);
    end
end

