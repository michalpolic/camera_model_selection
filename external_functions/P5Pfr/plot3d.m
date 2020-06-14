%h = plot3d(X,pars) - single matrix 3 x N plot in 3D
% 
% X    ... single matrix 3 x N
% pars ... other plot3 pars
%
% See also PLOT3

% (c) T.Pajdla, pajdla@cmp.felk.cvut.cz
% 5 May 2008
function h = plot3d(varargin)

X = varargin{1};
if ~isempty(X) 
    if size(X,1)==3
        h0 = plot3(X(1,:),X(2,:),X(3,:),varargin{2:end});
    elseif size(X,1)==2
        h0 = plot(X(1,:),X(2,:),varargin{2:end});
    else
        h0 = plot3(varargin{1:end});
    end
else
    h0=[];
end
if nargout>0
    h=h0;
end





