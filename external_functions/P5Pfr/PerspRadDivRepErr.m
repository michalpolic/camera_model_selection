% e = PespRadDivRepErr(C,X) - Perspective + radial distortion reprojection error
%
% C        = Cellarray of n camera structures, see X2u for 'KRCrd'
% X(1:3,:) = 3 x n image projections
% X(4:6(7),:) = 3(4) x n 3D points
% e        = n x 1 image reprojection errors for each camera

% 2017-04-30 pajdla@cvut.cz
% 
function e = PerspRadDivRepErr(C,X,C0)
if nargin>0
    if ~iscell(C)
        C = {C};
    end
    if size(X,1)<7
        X = a2h(X);
    end
    e = zeros(numel(C),size(X,2)); % initialize errors
    for i=1:numel(C)
        if C{i}.type~='KRCrd', error('C{%d}.type==''KRCrd'' required',i); end
        e(i,:) = vnorm(h2a(X(1:3,:))- X2u(X(4:7,:),C{i}));
    end
else
    e = true;
end
