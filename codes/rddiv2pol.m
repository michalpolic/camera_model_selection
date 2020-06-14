% Co = rddiv2pol(Ci,dmax,di) - inversion of the radial division undistortion to Brown polynomial distortion model conversion
%
% Ci  = camera description with radial division undistortion parameters 'KRCrd'
% Co  = camera description with polynomial radial distoriton parameters 'KRCp'
% dmax = maximal distorted radius, 1 implicit
% di   = points on which is the difference minimized, dmax//max(C.K([1 5]))*[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.95 1] implicit
% e    = error of the approximation

% T.Pajdla, pajdla@cvut.cz, 2017-04-08
function [C,e] = rddiv2pol(C,dmax,di)
if nargin>0
    if C.type == 'KRCrd'
        if nargin<2
            dmax = max(C.K([1 5]));
        end
        D = dmax/max(C.K([1 5]));
        if nargin<3
            di = D*[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.95 1];
        end
        k = [C.r(:)' zeros(1,3-length(C.r))]; % make k of length 3 if shorter
        ri = f(di,k);
        Sr04 = sum(ri.^4);
        Sr06 = sum(ri.^6);
        Sr08 = sum(ri.^8);
        Sr10 = sum(ri.^10);
        Sr12 = sum(ri.^12);
        Sr14 = sum(ri.^14);
        Sr3d = sum((ri.^3).*di);
        Sr5d = sum((ri.^5).*di);
        Sr7d = sum((ri.^7).*di);
        A = [Sr06 Sr08 Sr10
             Sr08 Sr10 Sr12
             Sr10 Sr12 Sr14];
        b = -[Sr04-Sr3d
            Sr06-Sr5d
            Sr08-Sr7d];
        p = A\b;
        C.r = p';
        C.type = 'KRCrp';
        e = di-g(f(di,k),p);
    else
        error('C.type = ''KRCrd'' required');
    end
else % unit tests
    % Test 1
    Cr.type = 'KRCrd';
    Cr.K = eye(3); Cr.R = eye(3); Cr.C = zeros(3,1);
    Cr.r = [-1e-1,-5e-2,-5e-2];
    [~,e] = rddiv2pol(Cr);
    C = all(abs(e)<1e-3);
    % Test 2
    Cr.K = [1000 0 0;0 1000 0; 0 0 1]; 
    Cr.r = [-1e-1,-5e-2,-5e-2];
    [~,e] = rddiv2pol(Cr);
    C(2) = all(abs(e)<1e-3);
    % Test 2
    Cr.K = [1000 0 0;0 1000 0; 0 0 1]; 
    Cr.r = [-1e-1,-5e-2,-5e-2];
    [~,e] = rddiv2pol(Cr,1100);
    C(3) = all(abs(e)<1.5e-3);    
end
end
function r = f(d,k)
    r = d./(1 + k(1)*d.^2 + k(2)*d.^4 + k(3)*d.^6);
end
function d = g(r,p)
    d = r.*(1 + p(1)*r.^2 + p(2)*r.^4 + p(3)*r.^6);
end

