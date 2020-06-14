% P = P2KRC(K,R,C) - Camera matrix P = K*R*[I -C]
%	 
%	P	    = camera calibration matrix ; size = 3x4
%	K	    = matrix of internal camera parameters
%	R	    = rotation matrix
%	C	    = camera center
%   or 
%   K       = struct K.K, K.R, K.C

% Tomas Pajdla, pajdla@cmp.felk.cvut.cz
% 2015-08-26
function P = KRC2P(K,R,C)
if isstruct(K)
    R = K.R;
    C = K.C;
    K = K.K;
end
P = K*R*[eye(3) -C];

