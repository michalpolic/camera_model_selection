function [ d ] = add_missmatches( d, missmatches, setting )
%ADD_MISSMATCHES - permute the ids of 3D points
    
    if max(missmatches) == 0
        return;
    end

    c_imgs = d.images.values;
    for i = 1:length(c_imgs)
        fprintf(repmat('\b',1,4));
        fprintf('%03d%%',ceil(100*i/length(c_imgs)));
        
        img = c_imgs{i};
        
        nobs = length(img.point3D_ids);
        if exist('setting','var') && isfield(setting,'permutation') ...
                && strcmp(setting.permutation,'RANDOM')
            % random permutation of subset of p3d ids
            permute_filter = rand(1,length(img.point3D_ids)) < missmatches;
            permuted_p3d_ids = img.point3D_ids(permute_filter);
            P = eye(length(permuted_p3d_ids));
            P = P(randperm(length(permuted_p3d_ids)),:);
            img.point3D_ids(permute_filter) = P * permuted_p3d_ids;
            changed_ids = find(permute_filter);
            changed_ids(diag(P) == 1) = [];
        else
            % permute the ids of observations which are close to each other
            D = sqrt((img.xys(:,1) - img.xys(:,1)').^2 + (img.xys(:,2) - img.xys(:,2)').^2);
            D = D + diag(inf(nobs,1));
            [~, ids] = sort(D(:));
            num_changed = round(missmatches * nobs);
            if mod(num_changed,2) ~= 0
                num_changed = num_changed + 1;
            end
            [permute_id1,permute_id2] = ind2sub([nobs,nobs], ids(1:num_changed));
            [~, unique_ids1] = unique(permute_id1);
            [~, unique_ids2] = unique(permute_id2);
            filter_ids = zeros(length(permute_id1),2);
            filter_ids(unique_ids1,1) = 1;
            filter_ids(unique_ids2,2) = 1;
            filter_ids = filter_ids(:,1) & filter_ids(:,2);
            permute_id1 = permute_id1(filter_ids);
            permute_id2 = permute_id2(filter_ids);
            img.point3D_ids(permute_id1) = img.point3D_ids(permute_id2);
        end
        
        % test of the correctnes of the permutation
        reconst_filter = img.point3D_ids ~= -1;
        pt3D_ids = img.point3D_ids(reconst_filter);
        [~,~,IB] = intersect(cell2mat(d.points3D.keys),pt3D_ids);
        if length(IB) ~= nobs
            warning('upsss');
        end
        
        % inliers / outliers
        img.inliers = ones(nobs,1);
        if exist('setting','var') && isfield(setting,'permutation') ...
                && strcmp(setting.permutation,'RANDOM')
            img.inliers(changed_ids) = 0;
        else
            img.inliers(permute_id1) = 0;
            img.inliers(permute_id2) = 0;
        end
        
        d.images(img.image_id) = img;
    end
end

