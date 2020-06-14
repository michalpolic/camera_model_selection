function [ d ] = align_coordiante_system( scene, refer_dir_d )
%ALIGN_COORDIANTE_SYSTEM - align the scene wrt reference coord. system
    d = clone_scene(scene);

    d_ref = struct();
    [d_ref.cameras, d_ref.images, d_ref.points3D] = read_model(refer_dir_d);

    % find corresponding images 
    c_imgs = d.images.values();
    ref_c_imgs = d_ref.images.values();
    img_names = cellfun(@(c)strtrim(c.name), c_imgs,'UniformOutput', false);
    ref_img_names = cellfun(@(c)strtrim(c.name), ref_c_imgs,'UniformOutput', false);
    [~,IA,IB] = intersect(img_names,ref_img_names);
    if isempty(IA)
        d = [];
        return;
    end
    
    % find camera centers 
    C = cell2mat(arrayfun(@(ioid) - c_imgs{ioid}.R' * c_imgs{ioid}.t, IA, 'UniformOutput', false)');
    %R = arrayfun(@(ioid) c_imgs{ioid}.R, IA, 'UniformOutput', false)';
    ref_C = cell2mat(arrayfun(@(ioid) - ref_c_imgs{ioid}.R' * ref_c_imgs{ioid}.t, IB, 'UniformOutput', false)');
    %ref_R = arrayfun(@(ioid) ref_c_imgs{ioid}.R, IB, 'UniformOutput', false)';
    
    % find transform
    [~, C_fit, tr] = procrustes(ref_C', C');                         
    %C_fit = C_fit';
    RTs = struct('R',tr.T', 't',tr.c(1,:)', 's',tr.b);     % C_fit = tr.b * tr.T' * C + tr.c';
    
%     % show the fit
%     figure(); hold on; axis equal; 
%     plot3(C(1,:),C(2,:),C(3,:),'r.'); 
%     plot3(ref_C(1,:),ref_C(2,:),ref_C(3,:),'g.');
%     plot3(C_fit(1,:),C_fit(2,:),C_fit(3,:),'b.');
        
    % transform all
    for i = 1:length(c_imgs)
        img = c_imgs{i};
        img_C = - img.R' * img.t;
        img_C = RTs.s * RTs.R * img_C + RTs.t;
        img.R = img.R * RTs.R';
        img.t = - img.R * img_C;
        img.q = r2q(img.R)';
        d.images(img.image_id) = img;
    end
    c_pts = d.points3D.values();
    for i = 1:length(c_pts)
        pt = c_pts{i};
        pt.xyz = RTs.s * RTs.R * pt.xyz + RTs.t;
        d.points3D(pt.point3D_id) = pt;
    end
end

