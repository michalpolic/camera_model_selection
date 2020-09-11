function [G, img_start_ids] = compose_obs_pts_graph( d )
%COMPOSE_OBS_PTS_GRAPH - cmopose the graph with links obs - pts
    t = 0;
    G = struct();
    G.obs = containers.Map('KeyType','uint32','ValueType','any');
    G.pts = containers.Map('KeyType','uint32','ValueType','any');
    c_imgs = d.images.values;
    c_pts = d.points3D.values;
    for i = 1:length(c_pts)
        G.pts(c_pts{i}.point3D_id) = [];
    end
    img_start_ids = zeros(1,length(c_imgs));
    for i = 1:length(c_imgs)
        img = c_imgs{i};
        point3D_ids = img.point3D_ids(img.point3D_ids ~= -1);
        for j = 1:length(point3D_ids)
            G.obs(t+j) = uint32([j t+j i img.image_id point3D_ids(j)]);   % [loc_id, glob_id, i, img_id, pt_id]
            G.pts(point3D_ids(j)) = [G.pts(point3D_ids(j)); uint32([point3D_ids(j) img.image_id t+j])];
        end
        img_start_ids(i) = t + 1;
        t = t + length(point3D_ids);
    end
end

