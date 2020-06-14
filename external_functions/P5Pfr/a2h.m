% X = a2h(x [,w]) - affine to homogeneous coordinates
% 
% X = [x; 1 1 1 ...] 

% (c) T.Pajdla, 2004-10-10
function X = a2h(x,w)

if nargin<2
    w = 1;
end
X = [x;w.*ones(1,size(x,2))];