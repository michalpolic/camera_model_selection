function [ inliers, model, params ] = verify_matches( obs1, obs2, pair_matches, K1, K2, params )
%VERIFY_MATCHES - verify matches and compute F, l1, l2 parameters 
    
    % Calibration matrix
    dts = struct();
    dts.K1 = K1;
    dts.K2 = K2;
    dts.pts1 = double(obs1);
    dts.pts2 = double(obs2);
    dts.matches = pair_matches;

    % Fundamental matrix + radial distortion using F10e method
    [modelF10e, params] = ransac(dts, params);
    
    % set output
    inliers = pair_matches(:,modelF10e.cset);
    model = modelF10e.geom;
   
%     % find focal
%     PP = E2PP(model.F');
%     for j = 1:length(PP{2})
%         [K2,R2,C2] = P2KRC(PP{2}{j});
%         K12 = K * K2;
%         model.fx = K12(1,1);
%         model.fy = K12(2,2);
%     end
end

