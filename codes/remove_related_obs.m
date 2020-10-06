function [ glob_ids ] = remove_related_obs( VG, obs_ids, nimgs )
%REMOVE_RELATED_OBS - return global ids not used in evaluation
    
    % clone the graph to allow editation
    nimg_obs = zeros(nimgs,1);
    G = struct();
    G.obs = containers.Map('KeyType','uint32','ValueType','any');
    G.pts = containers.Map('KeyType','uint32','ValueType','any');
    c_obs = VG.obs.values();
    for i = 1:length(c_obs)
        G.obs(i) = c_obs{i};
        nimg_obs(c_obs{i}(3)) = nimg_obs(c_obs{i}(3)) + 1;
    end
    c_pts = VG.pts.values();
    for i = 1:length(c_pts)
        G.pts(c_pts{i}(1)) = c_pts{i};
    end
   
    % go over all points and remove the related ones
    glob_ids = zeros(length(G.obs),1);
    glob_ids(obs_ids) = 1;
    for i = 1:length(obs_ids)
        if isKey(G.obs,obs_ids(i))
            tmp_obs_ids = G.obs(obs_ids(i));
            G.obs = remove(G.obs,obs_ids(i));
            nimg_obs(tmp_obs_ids(3)) = nimg_obs(tmp_obs_ids(3)) - 1;
            
            tmp_pts_ids = G.pts(tmp_obs_ids(5));
            tmp_pts_ids(tmp_obs_ids(4) == tmp_pts_ids(:,2),:) = [];
            if size(tmp_pts_ids,1) < 2
                if isKey(G.obs, tmp_pts_ids(3))
                    glob_ids(tmp_pts_ids(3)) = 1;
                    tmp_rem_obs = G.obs(tmp_pts_ids(3));
                    G.obs = remove(G.obs,tmp_pts_ids(3));
                    nimg_obs(tmp_rem_obs(3)) = nimg_obs(tmp_rem_obs(3)) - 1;
                end
                G.pts = remove(G.pts,tmp_obs_ids(5));
            else
                G.pts(tmp_obs_ids(5)) = tmp_pts_ids;
            end
        end
    end
    
    % save ids & check if all images has enough observations
    if sum(nimg_obs < 7) > 0
        glob_ids = [];
    else
        glob_ids = find(glob_ids);
    end
end

