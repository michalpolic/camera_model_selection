function [ corr_pts ] = filter_field_of_view3D( R, C, dpts )
    pairs = [1 2 3 4; 2 3 4 1];
    pts_cam = [-1 -1 1; 1 -1 1; 1 1 1; -1 1 1]';
    pts_world = h2a([R' C; 0 0 0 1]*a2h(pts_cam));

    Ndpts = size(dpts,2);
    vpts = dpts - repmat(C,1,Ndpts);
    D = true(1,Ndpts);
    for j = 1:4
        %plot3d([C pts_world(:,j)],'b-','LineWidth',3);

        v2 = pts_world(:,pairs(1,j)) - C;
        v1 = pts_world(:,pairs(2,j)) - C;
        D = D & (((v2(1) * v1(2)) * vpts(3,:) - (v2(3) * v1(2)) * vpts(1,:) + ...
                (v2(3) * v1(1)) * vpts(2,:) - (v2(1) * v1(3)) * vpts(2,:) + ...
                (v2(2) * v1(3)) * vpts(1,:) - (v2(2) * v1(1)) * vpts(3,:)) > 0); 
    end
    corr_pts = D';
end

