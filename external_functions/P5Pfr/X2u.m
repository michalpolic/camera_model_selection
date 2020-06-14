% [u,z] = X2u(X,C) - camera projection
%
%  X      ... 3(4) x n space points, 3 -> 1's augmented
%  C      ... camera description
%  C.type ... camera type:
%
%   'P'   - C - 3 x 4 camera projection matrix
%   'KRC' -
%                [1/bx s/f u0/f] - internal calibration matrix
%         C.K  = [0   1/by v0/f]   If f is in world units, true camera size
%                [0     0   1/f]   can be reconstruceted.
%         any non-zero multiple of C.K is equivalent for making projections
%
%         C.R  = 3x3 rotation matrix
%         C.C  = 3x1 camera center
%   'KRCrp'
%         C.r  = 1xN [p1 p2 ...] polynomial distortion coefficients
%   'KRCrd'
%         C.r  = 1x1 division model distortion parameter
%                model rd = (1-sqrt(1-4*C.r*ru^2))/(2*C.r*ru)
%                      ru = rd * 1/(1+C.r*rd^2)
%                      ru - undistorted radius, rd - distorted radius
%
%   CAHVOR     = see CAHVOR paper
%   CAHVORE    = see CAHVOR paper
%   'OCV'
%         C.R = rotation          ... option 1
%         C.C = 3x2 camera center ... option 1
%         C.A = [R -R*C;0 0 0 1]  ... option 2
%         C.r = radial distortion parameters (see OpenCV)
%         C.K = K matrix
%
%   'radtan' = KALIBR radtan model (perhaps a variation of
%                                   https://pdfs.semanticscholar.org/fac8/1d6320c6d25e7b0e4141038ba53a9e28a267.pdf
%                                   http://www.robots.ox.ac.uk/~cmei/articles/single_viewpoint_calib_mei_07.pdf
%                                   http://www.robots.ox.ac.uk/~cmei/articles/projection_model.pdf)
%         C.K = camera internal calibration matrix (I if fiels missing)
%         C.R = rotation (or affine - K*R)
%         C.C = camera projection center
%         C.k = [xi fu fv cu cv] - camera intrinsic prameters xi = omni paramter, K = [fu 0 cu;0 fv cv; 0 0 1]
%         C.r = [k1 k2 p1 p2] - k1, k2 radial, distortion, p1, p2 - tangential distortion
%         C.s = image size (cols x rows)
%         Projection: X -> u
%                     X  = K*R*[x;y;z]-K*R*C
%                     rz  = 1/(z + xi*||X||)
%                     xz = x * rz;
%                     yz = y * rz;
%                     d  = k1 * (xz^2+yz^2) + k2 * (xz^2+yz^2)^2
%                     p  = [xz + xz*d + 2*p1*xz*yz + p2*(xz^2+yz^2 + 2*xz^2)
%                           yz + yz*d + 2*p2*xz*yz + p1*(xz^2+yz^2 + 2*yz^2)]
%                     u  = [fu 0  cu] [p]
%                          [0  fv cv] [1]
%
% Backwards compatibility
%
%  C.type missing
%          C = P \in R^{3 x 4} or
%  C.type missing
%          C.K  ... internal calibration matrix
%          C.E  ... camera euclidean coordinate system transformation
%          C.r  ... polynomial radial distortion
%
% u ... 2 x n image projections
% z ... z coordinate of the direction vector (> for points infront of the camera)

% (c) T.Pajdla, 2017-02-01
function [u,z,d1,d2] = X2u(X,Ci)
if nargin>0
    % backwards compatibility of camera models
    if ~isa(Ci,'struct')
        C.P = Ci;
        C.type = 'P';
    else
        C = Ci;
    end
    if ~isfield(C,'type')
        C.type = 'KRC';
        C.f = norm(C.E(3,1:3)); % focal length
        C.E = C.E/C.f; % normalize to get rotation
        C.R = C.E(1:3,1:3); % rotation
        C.C = -C.R'*C.E(:,4); % camera center
    end
    cType = C.type;
    % normalize format of X
    if size(X,1)<4,
        X = [X;ones(1,size(X,2))];
    end
    % projections
    switch cType
        case {'P','KRC','KRCrp'}
            switch cType
                case 'P'
                    u = C.P*X;
                case {'KRC','KRCrp'}
                    u = C.R*[eye(3) -C.C]*X;
            end
            z = u(3,:);        
            u = h2a(u);
            switch cType
                case 'KRC'
                    u  = h2a(C.K*a2h(u));
                case 'KRCrp'
                    u = u(1:2,:);
                    if any(abs(C.r)>10*eps)
                        t = ones(1,size(u,2)); % the final radius parameter
                        r = sqrt(sum(u.^2));
                        for i=1:size(C.r,2)
                            t = t + C.r(i)*r.^(2*i);
                        end
                        u = ([1;1]*t).*u;
                    end
                    u  = h2a(C.K*a2h(u));
            end
        case 'KRCrd'
            if numel(C.r)>1, error('numel(C.r)==1 required for ''KRCrd'''); end
            v = C.R*[eye(3) -C.C]*X; % from delta to epsilon
            z = v(3,:);
            v = h2a(v); % normalize to have v(3,:)=1
            ru2 = v(1,:).^2+v(2,:).^2; % undistorted squared radius
            if true % works for fish-eye, i.e. when distorte image gets smaller on the image plane
                rd =  sqrt(1/2*(-2*C.r*ru2+1-(-4*C.r*ru2+1).^(1/2))/C.r^2./ru2);
            else % the other solution ... the choice not implemented yet
                rd =  sqrt(1/2*(-2*C.r*ru2+1+(-4*C.r*ru2+1).^(1/2))/C.r^2./ru2);
            end
            u = repmat(rd./sqrt(ru2),2,1).*v; % distort in epsilon
            u = h2a(C.K*a2h(u)); % to alpha
        case 'CAHVOR'
            if size(X,1)>3, X = X(1:3,:); end
            u = ones(3,size(X,2));
            oo = C.O*C.O'; % projector to unit O
            ox = eye(3)-oo; % perpediculator to unit O
            for i=1:size(X,2)
                Y = X(:,i)-C.C; % (2.51)
                t = sum((ox*Y).^2)/sum((oo*Y).^2); % (2.52)
                Z = Y+((t.^(1:size(C.R,2)))*C.R')*(ox*Y); % (2.53)
                z = Z(3,:);
                u(:,i) = [[C.H';C.V']*Z/(C.A'*Z);1]; % (2.54)
            end
        case 'CAHVORE'
            if size(X,1)>3, X = X(1:3,:); end
            for i=1:size(X,2)
                % solve equation
                %
                % sin(t)*(b-(t/sin(t)-1)*(e1+e2*t^2+e3*t^4+...))-a*cos(t) = 0
                %
                % for t. By the Newton method. Initializaze: t = atan(a/b)
                %
                % a = ||(I-O*O')*(X-C)||
                % b = ||(O*O')*(X-C)|| = O'*(X-C)
                oo = C.O*C.O'; % projector to unit O
                ox = eye(3)-oo; % perpediculator to unit O
                V = X(:,i)-C.C;
                a = sqrt(sum((ox*V).^2));
                b = sqrt(sum((oo*V).^2));
                % solve for ty
                ty = atan2(a,b);
                for j=1:6
                    f = ty.^(2*(0:size(C.E,1)-1))*C.E;
                    g = ty/sin(ty)-1;
                    e = sin(ty)*(b-f*g)-a*cos(ty);
                    df = (2*(1:size(C.E,1)-1)).*(ty.^(2*(1:size(C.E,1)-1)-1));
                    dg = (sin(ty)-ty*cos(ty))/(sin(ty)^2);
                    de = cos(ty)*(b-f*g)-sin(ty)*(df*g+f*dg)+a*sin(ty);
                    ty = ty-e/de;
                end
                f = ty.^(2*(0:size(C.E,1)-1))*C.E;
                s  = (ty/sin(ty)-1)*f; % (2.124)
                Cp = C.C + s*C.O; % (2.123)
                Y = X(:,i)-Cp; % (2.125)
                xi = sin(C.L*t)/(L*cos(max(0,L*t))); % (2.127)
                ttz = (1+(t.^(2*(0:size(C.R,2)))*C.R))*xi; % (2.126)
                tty = tan(ty);
                Z = ((ttz/tty)*ox+oo)*Y; % (2.129)
                z = Z(3,:);
                u(:,i) = [C.H';C.V']*Z/(C.A'*Z); % (2.54)
            end
        case 'OCV'
            if ~isfield(C,'A')
                C.A = [C.R -C.R*C.C;[0 0 0 1]]; % Metric projection matrix
            end
            Z = C.A*X;
            z = Z(3,:);
            p = h2a(h2a(Z)); % projection to the metric image
            r2 = sum(p.^2); % squared radius
            d1 = 1 + C.r(1)*r2 + C.r(2)*r2.*r2 + C.r(5)*r2.*r2.*r2;
            if (numel(C.r) == 8)
                d2 = 1 + C.r(6)*r2 + C.r(7)*r2.*r2 + C.r(8)*r2.*r2.*r2;
            else
                d2 = 1;
            end
            % radial distortion multiplier
            pp(1,:) = (d1./d2).*p(1,:)+2*C.r(3)*p(1,:).* p(2,:)+ C.r(4).*(r2 + 2*p(1,:).*p(1,:));
            pp(2,:) = (d1./d2).*p(2,:)+2*C.r(4)*p(1,:).* p(2,:)+ C.r(3).*(r2 + 2*p(2,:).*p(2,:));
            % to the image coordinate system
            u(1,:) = C.K(1,1)*pp(1,:) + C.K(1,3);
            u(2,:) = C.K(2,2)*pp(2,:) + C.K(2,3);
            u = a2h(u);
        case 'radtan'
            %         C.k = [xi fu fv cu cv] - camera intrinsic prameters xi = omni paramter, K = [fu 0 cu;0 fv cv; 0 0 1]
            %         C.r = [k1 k2 p1 p2] - k1, k2 radial, distortion, p1, p2 - tangential distortion
            %         Projection: X -> u
            %                     X  = [x;y;z]
            %                     rz  = 1/(z + xi*||X||)
            %                     xz = x * rz;
            %                     yz = y * rz;
            %                     d  = k1 * (xz^2+yz^2) + k2 * (xz^2+yz^2)^2
            %                     p  = [xz + xz*d + 2*p1*xz*yz + p2*(xz^2+yz^2 + 2*xz^2)
            %                           yz + yz*d + 2*p2*xz*yz + p1*(xz^2+yz^2 + 2*yz^2)]
            %                     u  = [fu 0  cu] [p]
            %                          [0  fv cv] [1]
            %
            if size(X,1)>3, X = X(1:3,:); end
            % omnidirectional projection (this is actually a form of a division model)
            if isfield(C,'K');
                C.R = C.K*C.R;
            end
            Y = [C.R -C.R*C.C]*a2h(X); % from the world coordinate system  delta to the camera coordinate system epsilon
            rz = 1./(Y(3,:)+C.k(1)*vnorm(Y));
            xz = Y(1,:).*rz;
            yz = Y(2,:).*rz;
            % distortion
            d  = C.r(1)*(xz.^2+yz.^2)+C.r(2)*(xz.^2+yz.^2).^2;
            p  = [xz + xz.*d + 2*C.r(3)*xz.*yz + C.r(4)*(3*xz.^2 +   yz.^2)
                  yz + yz.*d + 2*C.r(4)*xz.*yz + C.r(3)*(  xz.^2 + 3*yz.^2)];
            % to the image coordinate syste
            u = [C.k(2) 0 C.k(4);0 C.k(3) C.k(5)]*a2h(p);
            z = [];
    end
else % unit tests
    % perspective
    X = [0 1 1;0 0 0;0 0 1];
    P = eye(3,4);
    [uu,z] = X2u(X,P);
    u = max(vnorm(uu(:,3)-[1;0]))==0;
    % radtan
    X = [-1 2 3 -2;-1 -1 1 1;5 5 5 5];
    subfig(2,3,1); plot3d(X,'.');hold;grid;title('Scene')
    C.type = 'radtan';
    C.R = eye(3); % camera is looking up
    C.C = [0;0;0]; % camera is in the origin
    C.k = [2.4711347570226754, 1178.6271527551874, 1181.2165722170469, 639.9436056771921, 405.2208701362584];
    C.K = diag([1 1 1]); % [C.k(2) 0 C.k(3);0 C.k(3) C.k(4);0 0 1];
    C.r = [0.37213667906602127, 8.029412088629302, 0.0029824930755515755, 0.01107675622426885];
    C.s = [1280 800];
    camplot(C);axis equal;
    uu = X2u(X,C);
    vu = u2v(uu,C);
    vX = X2v(X,C); 
    u(2) = max(vnorm(unorm(vX)-unorm(vu)))<1e-15;
    % 'KRCrd'
    C = []; C.R = eye(3); C.K = eye(3); C.C = [0;0;0];
    C.type = 'KRCrd';
    C.r = -5e-6;
    uu = 500*(rand(2,100)-0.5); % distorted
    uv = a2h(uu./(1+C.r*(uu(1,:).^2+uu(2,:).^2))); % undistorted
    uw = X2u(uv,C);
    e = PerspRadDivRepErr(C,[a2h(uu);uv]);
    subfig(3,4,1); 
    plot3d(uu,'.r');hold;plot3d(uv,'.b');plot3d(uw,'or');axis equal;
    u(3) = max(vnorm(uu-uw))<1e-10 && max(e)<1e-10;
end