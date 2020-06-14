% [K,R] = kr3(A) - Matrix decomposition A = K*R, K triu, R rotation      
%
%	A 	= 3 x 3 matrix,
%	K	= upper triangular matrix
%	R	= rotation
%

% (c) T. Pajdla, pajdla@cmp.felk.cvut.cz
% 5 May 2008
function [K,R] = kr3(A)
 
R(3,:) = A(3,:)/vnorm(A(3,:));
R(1,:) = cross(A(2,:),R(3,:));
R(1,:) = R(1,:)/vnorm(R(1,:));
R(2,:) = cross(R(3,:),R(1,:));
K = A*R';