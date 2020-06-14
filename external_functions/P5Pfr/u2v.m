% v = u2v(u,C) - image point to unit ray direction vector in epsilon coordinate system
%
% u = 2 x n image points
% C = camera parameterers (see X2u.m)
% v = direction vector in the world coordinate system

% T.Pajdla, pajdla@cvut.cz, 2017-02-01
function v = u2v(u,Ci)
if nargin>0
    if isempty(u)||isempty(Ci)
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
    % projections
    switch C.type
        case 'P'
            K = P2KRC(C.P);
            u = unorm(a2h(u));
            v = K\u;
            v = unorm(v);
        case 'KRC'
            u = unorm(a2h(u));
            v = C.K\u;
            v = unorm(v);
        case {'KRCrp','CAHVOR','CAHVORE','OCV'}
            error('not implemented yet');
        case 'KRCrd'
            u = h2a(C.K\a2h(u)); % to epsilon with u(3,:)=1
            v = a2h(u./(1+C.r*(u(1,:).^2+u(2,:).^2))); % undistort
            v = unorm(v); % normlize
        case 'radtan'
            % from image to metric image coordinate system
            v = h2a([C.k(2) 0     C.k(4)
                    0      C.k(3) C.k(5)
                    0      0          1]\a2h(u));
            % undistort using the Newton method
            % vd = d(v)
            % f(v) = vd-d(v) = 0
            vd = v;
            for i=1:5 
                [vu,J] = radtanDF(v,C);
                for j=1:size(v,2)                    
                    v(:,j) = v(:,j) + J(:,:,j)\(vd(:,j)-vu(:,j));
                end
            end
            % back project in camera cs
            r2 = sum(v.*v);
            t = max(1+(1-C.k(1)^2)*r2,0);
            v = [v
                1-C.k(1)*(r2+1)./(C.k(1)+sqrt(t))];
            if isfield(C,'K');
                v = C.K\v;
            end
    end
else % unit tests
    % Test 1
    X = rand(3,10)-0.5 + 2*repmat([0;0;1],1,10); % 1x1x1 box of points centered at [0,0,2]
    subfig(2,3,1); plot3d(X,'.');hold;grid;title('Scene')
    C.type = 'radtan';
    C.R = eye(3); % camera is looking up
    C.C = [0;0;0]; % camera is in the origin
    C.k = [2.4711347570226754, 1178.6271527551874, 1181.2165722170469, 639.9436056771921, 405.2208701362584];
    C.K = [C.k(2) 0 C.k(3);0 C.k(3) C.k(4);0 0 1];
    C.r = [0.37213667906602127, 8.029412088629302, 0.0029824930755515755, 0.01107675622426885];
    C.s = [1280 800];
    camplot(C);axis equal;
    ud = X2u(X,C); % projection by the camera with distortion
    subfig(2,3,4); plot3d(ud,'.r'); axis equal; hold
    Cp = C; Cp.r = [0 0 0 0]; % projection by the omni camera without distortion
    up = X2u(X,Cp); 
    plot3d(up,'.b');
    uv = u2v(ud,C); % undistorted ray direction vector
    uu = X2u(uv,Cp); % undistorted image coordinates 
    plot3d(uu,'og');
    v(1) = all(vnorm(up-uu)<1e-8);
end
end
% radtan distortion function + the jacobian of the distortion
function [y,J] = radtanDF(x,C)
   d = C.r(1)*(x(1,:).^2+x(2,:).^2)+C.r(2)*(x(1,:).^2+x(2,:).^2).^2;
   y = [x(1,:) + x(1,:).*d + 2*C.r(3)*x(1,:).*x(2,:) + C.r(4)*(3*x(1,:).^2 +   x(2,:).^2)
        x(2,:) + x(2,:).*d + 2*C.r(4)*x(1,:).*x(2,:) + C.r(3)*(  x(1,:).^2 + 3*x(2,:).^2)];
   J(1,1,:) = 1+C.r(1)*(x(1,:).^2+x(2,:).^2)+C.r(2)*(x(1,:).^2+x(2,:).^2).^2+...
              x(1,:).*(2*C.r(1)*x(1,:)+4*C.r(2)*(x(1,:).^2+x(2,:).^2).*x(1,:))+...
              2*C.r(3)*x(2,:)+6*C.r(4)*x(1,:);
   J(1,2,:) = x(1,:).*(2*C.r(1)*x(2,:)+4*C.r(2)*(x(1,:).^2+x(2,:).^2).*x(2,:))+2*C.r(3)*x(1,:)+2*C.r(4)*x(2,:);
   J(2,1,:) = J(1,2,:);
   J(2,2,:) = 1+C.r(1)*(x(1,:).^2+x(2,:).^2)+C.r(2)*(x(1,:).^2+x(2,:).^2).^2+x(2,:).*(2*C.r(1)*x(2,:)+4*C.r(2)*(x(1,:).^2+x(2,:).^2).*x(2,:))+2*C.r(4)*x(1,:)+6*C.r(3)*x(2,:); 
end
