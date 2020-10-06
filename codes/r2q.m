% q = r2q(R) - rotation matrix to unit quaternion
%
% R = 3 x 3 rotation matrix (rotation matrix in a 4 x 4 hom transformation) 
% q = unit quaternion

% Tomas Pajdla, pajdla@cmp.felk.cvut.cz
% 2001-03-12
function q = r2q(R)
R = R(1:3,1:3);
c = trace(R)+1;
if abs(c)<10000*eps % 180 degrees
    S = R+eye(3);
    [~,mi]=max(vnorm(S));
    q = [0;S(:,mi)/vnorm(S(:,mi))];
else
    q = [sqrt(c)/2;
         (R(3,2)-R(2,3))/sqrt(c)/2;
         (R(1,3)-R(3,1))/sqrt(c)/2;
         (R(2,1)-R(1,2))/sqrt(c)/2];
    %q = q/vnorm(q); 
end
