% [K,R,C] = P2KRC(P) - Camera matrix P decomposition to K, R, C: P = K*R*[I -C]
%	 
%	P	    = camera calibration matrix ; size = 3x4
%	K	    = matrix of internal camera parameters
%	R	    = rotation matrix
%	C	    = camera center

% Tomas Pajdla, 2017-02-01
function [K,R,C] = P2KRC(P)
if nargin>0
    if ~isempty(P)
        if all(isfinite(P(:)))
            d = det(P(1:3,1:3));
            if abs(d)>100*eps
                P = P*sign(d);
            end
            B     = P(1:3,1:3);
            C     = -pinv(B)*P(:,4);
            [K,R] = kr3(B);
            K = sign(d)*K; % to have K*R*[eye(3) -C] = P
        else % to work for nan matrices
            K = triu(nan(3)); R = nan(3); C = nan(3,1);
        end
    else
        K = []; R = []; C = [];
    end
else % unit tests
    [k,r,c]=P2KRC([eye(3) zeros(3,1)]);
    K(1) = vnorm(m2v(k-eye(3)))==0;
    [k,r,c]=P2KRC([-eye(3) zeros(3,1)]);
    K(2) = vnorm(m2v(k-eye(3)))==0;    
end
return  
