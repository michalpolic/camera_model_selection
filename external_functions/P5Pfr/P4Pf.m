% P4P + unknown focal length 
% given a set of 4x 2D<->3D correspondences, calculate camera pose and the 
% camera focal length.
%
% by Martin Bujnak, (c)apr2008
%
%
% Please refer to the following paper, when using this code : 
%
%      Bujnak, M., Kukelova, Z., and Pajdla, T. A general solution to the p4p
%      problem for camera with unknown focal length. CVPR 2008, Anchorage, 
%      Alaska, USA, June 2008
%
%
% function [f R t] = P4Pf(m2D, M3D)
%
% input:
%
%  m2D - 2x4 matrix with 4x2D measuremets
%  M3D - 3x4 matrix with corresponding 3D points
%
% output:
%
%  f - vector with N focal lengths
%  R - 3x3xN matrix with N rotation matrices
%  t - 3xN matrix with N translation matrices
%
%  following equation holds for each solution
%
%      lambda*m2D = diag([f(i) f(i) 1])*[R(:,:,i) t(:,i)] * M3D

function [f R t] = P4Pf(m2D, M3D)

    tol = 2.2204e-10;

    %normalize 2D, 3D
    
    % shift 3D data so that variance = sqrt(2), mean = 0
    mean3d = (sum(M3D') / 4);
    M3D = M3D - repmat(mean3d', 1, 4);

    % variance (isotropic)
    var = (sum( sqrt(sum( M3D.^2 ) ) ) / 4);
    M3D = (1/var)*M3D;

    % scale 2D data
    var2d = (sum( sqrt(sum( m2D.^2 ) ) ) / 4);
    m2D = (1/var2d)*m2D;

    %caclulate quadratic distances between 3D points
    glab = (sum((M3D(:,1)-M3D(:,2)).^2));
    glac = (sum((M3D(:,1)-M3D(:,3)).^2));
    glad = (sum((M3D(:,1)-M3D(:,4)).^2));
    glbc = (sum((M3D(:,2)-M3D(:,3)).^2));
    glbd = (sum((M3D(:,2)-M3D(:,4)).^2));
    glcd = (sum((M3D(:,3)-M3D(:,4)).^2));
    
    if glab*glac*glad*glbc*glbd*glcd < tol
        
        % initial solution degeneracy - invalid input
        R = [];
        t = [];
        f = [];
        return;
    end

    % To use pure MATLAB code, uncomment following line and remove all code 
    % until "recover camera rotation and translation" comment.
    % [f zb zc zd] = p4pfcode(glab, glac, glad, glbc, glbd, glcd, m2D(1,1), m2D(2,1), m2D(1,2), m2D(2,2), m2D(1,3), m2D(2,3), m2D(1,4), m2D(2,4));
    
    % call helper
    [A] = p4pfmex([glab, glac, glad, glbc, glbd, glcd], m2D(:,1), m2D(:,2), m2D(:,3), m2D(:,4));
    [V D] = eig(A');
	sol =  V([2, 3, 4, 5],:)./(ones(4,1)*V(1,:));

	if (find(isnan(sol(:))) > 0)
		
        R = [];
        t = [];
        f = [];

	else
		
		I = find(not(imag( sol(4,:) )));
        fidx = find(sol(4, I) > 0);
    
        f = sqrt(sol(4, I(fidx)));
		zd = sol(1, I(fidx));
		zc = sol(2, I(fidx));
		zb = sol(3, I(fidx));
    
        % recover camera rotation and translation
        lcnt = length(f);
        if lcnt > 0

            for i=1:lcnt

                % create p3d points in a camera coordinate system (using depths)

                p3dc(:, 1) =     1 * [m2D(:, 1); f(i)];
                p3dc(:, 2) = zb(i) * [m2D(:, 2); f(i)];
                p3dc(:, 3) = zc(i) * [m2D(:, 3); f(i)];
                p3dc(:, 4) = zd(i) * [m2D(:, 4); f(i)];

                % fix scale (recover 'za')
                d(1) = sqrt(glab / (sum((p3dc(:,1)-p3dc(:,2)).^2)));
                d(2) = sqrt(glac / (sum((p3dc(:,1)-p3dc(:,3)).^2)));
                d(3) = sqrt(glad / (sum((p3dc(:,1)-p3dc(:,4)).^2)));
                d(4) = sqrt(glbc / (sum((p3dc(:,2)-p3dc(:,3)).^2)));
                d(5) = sqrt(glbd / (sum((p3dc(:,2)-p3dc(:,4)).^2)));
                d(6) = sqrt(glcd / (sum((p3dc(:,3)-p3dc(:,4)).^2)));

                % all d(i) should be equal...
                %gta = median(d);
                gta = sum(d) ./ 6;

                p3dc = gta * p3dc;

                % calc camera
                [Rr tt] = GetRigidTransform2(M3D, p3dc, false);

                R(:,:,i)=Rr;
                t(:,i)=var*tt - Rr*mean3d';
                f(i)=var2d*f(i);
            end
            
        else
            
            R=[];
            t=[];
        end
	end
end
