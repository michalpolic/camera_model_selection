% R = a2r(v,a) - rotation matrix from axis-angle representation
%
% v = rotation axis 
% a = angle [rad] or [cos(a) sin(a)]
% R = 3 x 3 rotation matrix 

% Tomas Pajdla, pajdla@cmp.felk.cvut.cz
% 2016-03-21
function R = a2r(v,a)
v = v/vnorm(v);
if numel(a)<2
    a = [cos(a) sin(a)];
end    
R = a(1)*eye(3) + (1-a(1))*v*v' + a(2)*xx(v);