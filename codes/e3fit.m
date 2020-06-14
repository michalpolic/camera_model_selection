%[E,Ve,rW,res,rs,rres,dX,s] = e3fit(X1,X2,W,mode,par) - Finds E(3) transformation minimizing LMSq/LSQ distance between two data sets
%
%
%       function [E,Ve,rW,res,rs,rres,dX,s] = e3fit(X1,X2,W,mode,par)
%
%	X1,X2 = two registered cloud of 3-D points, one point ~ one row
%	W     = a vector of weights, if missingt, ones are used
%	mode  = 0 or missing ... least squares minimization
%
%					   min sum (X1 - s*R * ( X2 - T))^2
%
%					   par is not used
%			  1            ... least median squares minimization
%					   par(1) = number of random samples,
%					            0 means all combinations
%			 	           par(2) = outlier cutoff threshold
%					   par(3) = robust scale multiplier cut off
%					   r_i is outlier <=>  (r_i > par(3)*robust_scale) || r_i > par(2)
%
%			  2 	       ... least median squares followed by
%					   trimmed least squares. Outliers are
%					   removed.
%
%
%	E		= 4x4 matrix of the euclidean transformation
%			  [X1 1] = E * [X2 1] ~ R * (X2 - T)
%	Ve		= variance matrix of E
%	rs		= robust scale esimate, [4] p. 202, eq. (1.3)
%	rW		= weights after outlier edetection, outliers have weight 0
%	res		= residuals
%	rres	= vector of residuals for the best fit from MLSQ
%	dX		= difference vector
%   s       = scale
%
%       See also E3,  APLE3.

%	Author: 	Tomas Pajdla, Tomas.Pajdla@esat.kuleuven.ac.be
%					    pajdla@vision.felk.cvut.cz
%			09/02/94 ESAT-MI2, KU Leuven
%	Documentation:  [1] K.Kanatani: Analysis of Rotation Fiting, PAMI 16(5):543--549, 1994.
%			[2] S.Umeyama : Least-Squares Estimation of Transformation Parameters
%				        Between Two Point Patterns, PAMI 13(4):377--381, 1991.
%			[3] K.Arun et al.: Least-Squares Fitting of Two 3-D Point Sets,
%				           PAMI 9(5):699--701, 1987.
%			[4] P.Rousseuw, A.Leroy: Robust Regression and Outlier Detection,
%					    John Willey & Sons, 1987, ISBN:0-471-85233-3.
%	Language: 	Matlab 4.2, (c) MathWorks
%       Last change  : $Id: e3fit.m,v 1.1 2005/04/28 16:54:38 pajdla Exp $
%       Status       : Ready ($Source: /home/cvs/Matlab/geometry/e3fit.m,v $)
%
function [E,Ve,W,res,rs,rres,dXt,s] = e3fit(X1,X2,W,mode,par)

if nargin < 3
    W    = ones(size(X1,1),1);
end
if nargin < 4
    mode = 0;
end

W  = W./sum(W(:));

if size(X1,1) < 3
    res    = 0;
    rs     = 0;
    rres   = 0;
    dXt    = 0;
    E      = zeros(4);
    Ve     = 'not implemented';
    return
end

%%
% Robust estimation and outlier detection
%          Median least squares
%%

if (mode == 1)|(mode==2)
    samplNum    = par(1);
    cutOff      = par(2);
    rScaleLevel = par(3);
    pNum     = size(X1,1);
    
    rand('seed',sum(100*clock));			% get random point triples of size samplNum,
    % no two indices in a point triple can be the same
    ridx   = [];
    snKoef = 2;
    while (size(ridx,1)~=samplNum)
        ridx = round((pNum-1)*(rand(3,snKoef*samplNum)))+1;
        ridx = [ridx ; ridx(1,:)];
        didx = diff(ridx);
        uidx = all(abs(didx));
        ridx = (ridx(1:3,uidx))';
        ridx = ridx(1:min(samplNum,size(ridx,1)),:);
        snKoef = 2 * snKoef;
    end
    
    for i = 1:size(ridx,1)
        if rem(i,50)==0
            disp(['e3fit:LMSQ:doing sample No. ' sprintf('%d',i) ' from ' sprintf('%d',size(ridx,1)) ' samples.']);
        end
        
        x1      = X1(ridx(i,:),:);					% for all triples
        x2      = X2(ridx(i,:),:);
        w       = W(ridx(i,:),:);
        w       = diag(w./sum(w(:)));
        
        x10     = sum(w*x1);						% center of mass
        x20     = sum(w*x2);
        m1      = [x1(:,1)-x10(1) x1(:,2)-x10(2) x1(:,3)-x10(3)];	% directions
        m2      = [x2(:,1)-x20(1) x2(:,2)-x20(2) x2(:,3)-x20(3)];
        
        K       =   w(1)*(m1(1,:))'*m2(1,:)...
            + w(2)*(m1(2,:))'*m2(2,:)...
            + w(3)*(m1(3,:))'*m2(3,:);				% direction correlation matrix
        
        [u,s,v] = svd(K);
        r       = u*diag([1 1 det(u)*det(v)])*v'; % rotation matrix
        t       = x20 - x10*r;					% translation vector
        
        dX      = (X1 - ([X2(:,1)-t(1) X2(:,2)-t(2) X2(:,3)-t(3)])*r')';
        e       = dot(dX,dX)*W;					% error
        se(i)   = median(e);
        st(i,:) = t;
        sr(i,:) = reshape(r,1,9);
    end
    
    [mme,mmi] = min(se);					% find minimal median lsq error
    t         = st(mmi,:);
    r         = reshape(sr(mmi,:),3,3);
    dX        = (X1 - ([X2(:,1)-t(1) X2(:,2)-t(2) X2(:,3)-t(3)])*r')';
    rs        = 1.4826*(1+5/(max(pNum,7)-6))*sqrt(mme);
    rres      = sqrt((dot(dX,dX))');
    W         = (rres<=rScaleLevel*rs).*(rres<=cutOff).*W;
    W         = sdiv(W,sum(W(:)));
end


%%
% Least squares solution
%
%%

if (mode == 0)|(mode==2)
    if sum(W(:)>eps)>2
        w = replica(W,ones(1,size(X1,2)));
        
        X10     = sum(w.*X1);				        % center of mass
        X20     = sum(w.*X2);
        m1      = [X1(:,1)-X10(1) X1(:,2)-X10(2) X1(:,3)-X10(3)];	% directions
        m2      = [X2(:,1)-X20(1) X2(:,2)-X20(2) X2(:,3)-X20(3)];
        
        K       = zeros(3,3);					% direction correlation matrix
        for i=1:size(m1,1)
            K      = K + W(i)*(m1(i,:))'*m2(i,:);
        end
        
        [u,s,v] = svd(K);
        r       = u*diag([1 1 det(u)*det(v)])*v';% rotation matrix
        t       = X20 - X10*r;					% translation vector
        
        dX      = (X1 - ([X2(:,1)-t(1) X2(:,2)-t(2) X2(:,3)-t(3)])*r')';
        res     = (sqrt(dot(dX,dX)))';
    else
        r   = zeros(3);
        t   = zeros(1,3);
        res = zeros(size(dX,2),1);
    end
end

Ve  = 'not implemented';
dXt = dX';

X = r*m2';
Y = m1';
w = [1;1;1]*W'; w=w/sum(abs(W(:)));
X = X.*w;
Y = Y.*w;
s = sum(X(:)'*Y(:))/sum(X(:)'*X(:));
E   = [ r -r*t'/s ; 0 0 0 1];


if ~exist('res','var'), res = []; end
if ~exist('rs','var'), rs = []; end
if ~exist('rres','var'), rres = []; end
return
