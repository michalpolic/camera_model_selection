function [u, X, pt3D_ids, u_ids] = img_uX(img, d)
    reconst_filter = img.point3D_ids ~= -1;
    u = img.xys(reconst_filter,:)';
    pt3D_ids = img.point3D_ids(reconst_filter);
    XX = arrayfun(@(pt_id)d.points3D(pt_id).xyz,pt3D_ids,'UniformOutput', false);
    if size(XX,1) ~= 1
        XX = XX';
    end
    X = cell2mat(XX);
    u_ids = find(reconst_filter);
end
