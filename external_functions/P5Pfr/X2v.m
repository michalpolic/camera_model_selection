%  v = X2v(X,C) - omnidirectional camera projection
%
%  X      ... 3(4) x n space points, 3 -> 1's augmented
%  C      ... camera description
%  C.type ... camera type:
%  see X2u for camera types
%
%  v ... 3 x n ray direction vectors 

% (c) T.Pajdla 2017-02-01
function v = X2v(X,Ci)
if isempty(X)||isempty(Ci)
    v = [];
    return
end
% backwards compatibility of camera models
if ~isa(Ci,'struct')
    C.P = Ci; 
    C.type = 'P';
else
    C = Ci;
end
if ~isfield(C,'type')
    C.type = 'KRC';
end
% normalize format of X
if size(X,1)<4 
    X = a2h(X);
end
% projections
switch C.type
    case 'P'
        [~,R,C] = P2KRC(C.P);
        v = R*[eye(3) -C]*X;
        v = unorm(v);
    case {'KRC','KRCrd','KRCrp','OCV','radtan'}
        v = C.R*[eye(3) -C.C]*X;
        v = unorm(v);
    case {'CAHVOR','CAHVORE'}
        error('not implemented');
end