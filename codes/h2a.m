% x = h2a(X[,w]) - homogeneous to affine coordinates
% 
% X        ... homogeneous coordinates in columns
% w(i) = 0 ... point at infinity
% x        ... affine coordinates in columns

% (c) T.Pajdla, 2004-10-10
function x = h2a(X,w)
x      = X(1:end-1,:);
xe     = X(end,:);
if nargin<2
    %if size(x,2)>1
            x = x./(ones(size(x,1),1)*xe); % x = bsxfun(@rdivide,x,xe); slower
    %else
    %    x = x./(ones(size(x,1),1)*xe');
    %end
else
    w = logical(w(:)');
    %if size(x,2)>1
        if any(w)
            x(:,w) = x(:,w)./(ones(size(x,1),1)*xe(w)); % x(:,w) = bsxfun(@rdivide,x(:,w),xe(w)); slower
        end
    %elseif w
    %    x = x./(ones(size(x,1),1)*xe');
    %end
end