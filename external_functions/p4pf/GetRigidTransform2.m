% find rigid transformation (rotation translation) from p1->p2 given
% 3 or more points in the 3D space
%
% based on : K.Arun, T.Huangs, D.Blostein. Least-squares  
%            fitting of two 3D point sets IEEE PAMI 1987
%
% by Martin Bujnak, nov2007
%
%function [R t] = GetRigidTransform(p1, p2, bLeftHandSystem)
% p1 - 3xN matrix with reference 3D points
% p2 - 3xN matrix with target 3D points
% bLeftHandSystem - camera coordinate system

function [R t] = GetRigidTransform2(p1, p2, bLeftHandSystem)

    N = size(p1, 2);

    % shift centers of gravity to the origin
    p1mean = sum(p1, 2) / N;
    p2mean = sum(p2, 2) / N;

    p1 = p1 - repmat(p1mean, 1, N);
    p2 = p2 - repmat(p2mean, 1, N);

    % normalize to unit size
    u1 = p1 .* repmat(1./sqrt(sum(p1.^2)), 3, 1);
    u2 = p2 .* repmat(1./sqrt(sum(p2.^2)), 3, 1);

    % calc rotation
    C = u2 * u1';
    [U S V] = svd(C);
    
    % fit to rotation space
    S(1,1) = sign(S(1,1));
    
    S(2,2) = sign(S(2,2));
    if bLeftHandSystem
        
        S(3,3) = -sign(det(U*V')); 
    else
        S(3,3) = sign(det(U*V'));
    end

    R = U*S*V';
    t = (-R*p1mean + p2mean);

end