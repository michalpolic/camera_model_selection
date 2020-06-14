% Cm = P5Pfr(u,X,C) - 5pt Minimal Absolute Pose Problem Solver for principal point at [0;0]
%
% C  = camera structure, see X2u.m, 'KRCrd' supported 
% u  = 2 x 5 image projections
% X  = 3 x 5 3D points
% Cm = cellarray of camera structures
%
% [1] Z Kukelova, M Bujnak, T Pajdla. Real-time solution to the absolute pose problem with unknown radial distortion and focal length. ICCV 2013.

% T. Pajdla, pajdla@cvut.cz
% 2015-09-06
function Cm = P5Pfr(u,X,C0)
if nargin>0
    if nargin<3
        C0.type = 'KRcrd';
        C0.r = 0;
    end
    if C0.type ~= 'KRcrd' 
        error('C.type = ''KRcrd'' required'); 
    end
    if ~isfield(C0,'r')
        C0.r = 0;
    end
    if numel(C0.r)>3
        error('1 <= numel(C.r) <= 3 required');
    end
    if size(u,1)==3
        u = h2a(u);
    end
    if size(u,2)==5 % minimal case
        A = zeros(5,8); % Eliminate all linear stuff
        % Maple: trn(diag(<-1,1>).u[[2,1],i]),trn(a2h(X[..,i])))
        for i=1:size(A,1)
            A(i,:) = kron([-u(2,i) u(1,i)],[X(:,i)' 1]);
        end
        % 3D Nullspace
        % [~,~,N] = svd(A);
        % N = N(:,end-2:end);
        N = nulld(A,3); 
        %
        if false
            N = fliplr(rref(fliplr(N')))'; % to check w.r.t. the Maple code
            N = unorm(N);
        end
        % Construct the matrix C
        C =[N(1:3,1)'*N(5:7,1),                    N(1:3,1)'*N(5:7,2)+N(1:3,2)'*N(5:7,1),                                         N(1:3,1)'*N(5:7,3)+N(1:3,3)'*N(5:7,1),                                         N(1:3,2)'*N(5:7,2),                    N(1:3,2)'*N(5:7,3)+N(1:3,3)'*N(5:7,2),                                         N(1:3,3)'*N(5:7,3);
            N(1:3,1)'*N(1:3,1)-N(5:7,1)'*N(5:7,1), N(1:3,1)'*N(1:3,2)+N(1:3,2)'*N(1:3,1)-(N(5:7,1)'*N(5:7,2)+N(5:7,2)'*N(5:7,1)), N(1:3,1)'*N(1:3,3)+N(1:3,3)'*N(1:3,1)-(N(5:7,1)'*N(5:7,3)+N(5:7,3)'*N(5:7,1)), N(1:3,2)'*N(1:3,2)-N(5:7,2)'*N(5:7,2), N(1:3,2)'*N(1:3,3)+N(1:3,3)'*N(1:3,2)-(N(5:7,2)'*N(5:7,3)+N(5:7,3)'*N(5:7,2)), N(1:3,3)'*N(1:3,3)-N(5:7,3)'*N(5:7,3)];
        % Normalize C to get reasonable numbers when computing d
        C = diag(size(C,2)./[vnorm(C(1,:)) vnorm(C(2,:))])*C;
        % Determinant coefficients
        d =[  C(1,1)^2*C(2,4)^2-C(1,1)*C(1,2)*C(2,2)*C(2,4)-2*C(1,1)*C(1,4)*C(2,1)*C(2,4)+C(1,1)*C(1,4)*C(2,2)^2+C(1,2)^2*C(2,1)*C(2,4)-C(1,2)*C(1,4)*C(2,1)*C(2,2)+C(1,4)^2*C(2,1)^2 
             -C(1,1)*C(1,2)*C(2,4)*C(2,5)+2*C(1,1)*C(1,3)*C(2,4)^2+2*C(1,1)*C(1,4)*C(2,2)*C(2,5)-2*C(1,1)*C(1,4)*C(2,3)*C(2,4)-C(1,1)*C(1,5)*C(2,2)*C(2,4)+C(1,2)^2*C(2,3)*C(2,4)-C(1,2)*C(1,3)*C(2,2)*C(2,4)-C(1,2)*C(1,4)*C(2,1)*C(2,5)-C(1,2)*C(1,4)*C(2,2)*C(2,3)+2*C(1,2)*C(1,5)*C(2,1)*C(2,4)-2*C(1,3)*C(1,4)*C(2,1)*C(2,4)+C(1,3)*C(1,4)*C(2,2)^2+2*C(1,4)^2*C(2,1)*C(2,3)-C(1,4)*C(1,5)*C(2,1)*C(2,2)
           -2*C(1,1)*C(1,4)*C(2,4)*C(2,6)+C(1,1)*C(1,4)*C(2,5)^2-C(1,1)*C(1,5)*C(2,4)*C(2,5)+2*C(1,1)*C(1,6)*C(2,4)^2+C(1,2)^2*C(2,4)*C(2,6)-C(1,2)*C(1,3)*C(2,4)*C(2,5)-C(1,2)*C(1,4)*C(2,2)*C(2,6)-C(1,2)*C(1,4)*C(2,3)*C(2,5)+2*C(1,2)*C(1,5)*C(2,3)*C(2,4)-C(1,2)*C(1,6)*C(2,2)*C(2,4)+C(1,3)^2*C(2,4)^2+2*C(1,3)*C(1,4)*C(2,2)*C(2,5)-2*C(1,3)*C(1,4)*C(2,3)*C(2,4)-C(1,3)*C(1,5)*C(2,2)*C(2,4)+2*C(1,4)^2*C(2,1)*C(2,6)+C(1,4)^2*C(2,3)^2-C(1,4)*C(1,5)*C(2,1)*C(2,5)-C(1,4)*C(1,5)*C(2,2)*C(2,3)-2*C(1,4)*C(1,6)*C(2,1)*C(2,4)+C(1,4)*C(1,6)*C(2,2)^2+C(1,5)^2*C(2,1)*C(2,4)
             -C(1,2)*C(1,4)*C(2,5)*C(2,6)+2*C(1,2)*C(1,5)*C(2,4)*C(2,6)-C(1,2)*C(1,6)*C(2,4)*C(2,5)-2*C(1,3)*C(1,4)*C(2,4)*C(2,6)+C(1,3)*C(1,4)*C(2,5)^2-C(1,3)*C(1,5)*C(2,4)*C(2,5)+2*C(1,3)*C(1,6)*C(2,4)^2+2*C(1,4)^2*C(2,3)*C(2,6)-C(1,4)*C(1,5)*C(2,2)*C(2,6)-C(1,4)*C(1,5)*C(2,3)*C(2,5)+2*C(1,4)*C(1,6)*C(2,2)*C(2,5)-2*C(1,4)*C(1,6)*C(2,3)*C(2,4)+C(1,5)^2*C(2,3)*C(2,4)-C(1,5)*C(1,6)*C(2,2)*C(2,4)
              C(1,4)^2*C(2,6)^2-C(1,4)*C(1,5)*C(2,5)*C(2,6)-2*C(1,4)*C(1,6)*C(2,4)*C(2,6)+C(1,4)*C(1,6)*C(2,5)^2+C(1,5)^2*C(2,4)*C(2,6)-C(1,5)*C(1,6)*C(2,4)*C(2,5)+C(1,6)^2*C(2,4)^2];
        % Companion matrix
        d = d/d(1); 
        M =[0,0,0,-d(5); 1,0,0,-d(4); 0,1,0,-d(3); 0,0,1,-d(2)];        
        % solve it
        g1 = eig(M);
        % select real sols of g1
        g1 = g1(abs(imag(g1))<eps); 
        if isempty(g1)
            Cm = {}; 
            return; 
        end
        % get g2: Sg1*<g2^3,g2^2,g2,1>=0
        % SG1:=<<C14|C12*g1+C15|C11*g1^2+C13*g1+C16|0>, 
        %       <  0|C14       |C12*g1+C15         |C11*g1^2+C13*g1+C16>,
        %       <C24|C22*g1+C25|C21*g1^2+C23*g1+C26|0>, 
        %       <  0|C24       |C22*g1+C25         |C21*g1^2+C23*g1+C26>>;
        g2 = zeros(size(g1));
        for i=1:numel(g1)
            MG2 = [C(1,4), C(1,2)*g1(i)+C(1,5), C(1,1)*g1(i)^2+C(1,3)*g1(i)+C(1,6), 0
                        0, C(1,4)             , C(1,2)*g1(i)+C(1,5)               , C(1,1)*g1(i)^2+C(1,3)*g1(i)+C(1,6)
                   C(2,4), C(2,2)*g1(i)+C(2,5), C(2,1)*g1(i)^2+C(2,3)*g1(i)+C(2,6), 0
                        0, C(2,4)             , C(2,2)*g1(i)+C(2,5)               , C(2,1)*g1(i)^2+C(2,3)*g1(i)+C(2,6)];
            % [~,~,x] = svd(MG2);
            % g2(i) = x(3,end)/x(4,end);
            x = nulld(MG2,1); 
            g2(i) = x(3)/x(4);
        end
        % Get P
        tk = cell(1,numel(g1)); 
        P = cell(1,numel(g1)); 
        for i=1:numel(g1) % for all pairs of solutions [g1,g2]
            % The first two rows of P (P:=zip((g1,g2)->N[1]*g1+N[2]*g2+N[3],G1,G2):)
            P{i} = N(:,1)*g1(i)+N(:,2)*g2(i)+N(:,3);
            P{i} = reshape(P{i},4,2)';
            P{i} = diag(1./vnorm(P{i}(:,1:3)'))*P{i};
            % P{i}(3,1:3) = P{i}(1,1:3) x P{i}(2,1:3)
            P{i}(3,:) = [P{i}(1,2)*P{i}(2,3)-P{i}(1,3)*P{i}(2,2) -P{i}(1,1)*P{i}(2,3)+P{i}(1,3)*P{i}(2,1) P{i}(1,1)*P{i}(2,2)-P{i}(1,2)*P{i}(2,1) 0];
            % Form equations on k p34 and t=1/f: B <p34,t,k1,k2^2,k3^3,1>  = 0
            B = zeros(size(u,2),6);
            for j=1:size(u,2) % for all point pairs [u, X]
                r2  = u(1,j)^2+u(2,j)^2; % temporary vals
                ee11 = P{i}(1,:)*[X(:,j);1];
                ee21 = P{i}(2,:)*[X(:,j);1];
                ee31 = P{i}(3,1:3)*X(:,j);
                ee32 = u(2,j)*ee31;
                ee33 =-u(1,j)*ee31;
                if abs(u(2,j))>abs(u(1,j)) % fill in the matrix
                    B(j,:) = [ u(2,j) ee32 [-r2 -r2^2 -r2^3]*ee21 -ee21];
                else
                    B(j,:) = [-u(1,j) ee33 [ r2  r2^2  r2^3]*ee11  ee11];
                end
            end
            U = [eye(6,2+numel(C0.r)) [zeros(2+numel(C0.r),1);zeros(3-numel(C0.r),1);1]]; % select columns depending on the number of pars in C.r
            B = B*U; 
            V = nulld(B,1); % find the right 1D null space
            tk{i} = V/V(end);
            % make f positive
            if tk{i}(2)<0
                tk{i}(1:2) = - tk{i}(1:2);
                P{i}(1:2,:) = - P{i}(1:2,:);
            end
            P{i}(3,4) = tk{i}(1)/tk{i}(2);
            Cm{i}.type = 'KRCrd';
            Cm{i}.K = diag([1/tk{i}(2)*[1 1] 1]); 
            Cm{i}.R = P{i}(1:3,1:3);
            Cm{i}.C = -Cm{i}.R'*P{i}(:,4);
            Cm{i}.r = tk{i}(3:end-1);
            % In [1] we have
            % [        u-u0             ]   [f 0 0]
            % [        v-v0             ] = [0 f 0] [R | -R*C] [X]
            % [1 + r*((u-u0)^2+(v-v0)^2)]   [0 0 1]            [1]
            % but we want
            % [             (u-u0)/f              ]  
            % [             (v-v0)/f              ] = [R | -R*C] [X]
            % [1 + (r*f^2)*((u-u0)^2+(v-v0)^2)/f^2]              [1]
            % instead not deal with f dependent r
            Cm{i}.r = Cm{i}.r.*(Cm{i}.K(1,1).^(2*(1:numel(Cm{i}.r))'));
        end
        % check errors
        for i=1:numel(Cm)
            if numel(Cm{i}.r)==1
                du(i,:) = abs(vnorm(u - X2u(X,Cm{i})));
            else
                du(i,:) = nan(1,size(u,2));
            end
        end
        du;
    else % nonminimal case for LO
        error('not implemented');
    end
else % unit tests
    % test 1 f = 10 r = -1e-1
    X = [9,  10, -10, -11, 0
        10, -10,  -9,  10, 0
        11,   9,  10,  11, 7];
    u = [756.69, 1153.3, -667.71, -805.79, 91.856
         917.14, -882.75, -810.95, 663.88, 4.4344]/100;     
    C = P5Pfr(u,X,struct('type','KRCrd'));
    e = PerspRadDivRepErr(C,[a2h(u);X]);
    Cm = abs(C{2}.K(1,1)-10)<0.002 && abs(C{2}.r-(-1e-1))<1e-4 && max(e(2,:))<0.002;
    % test 2 f = 1000 r = -1e-1
    u = [756.69, 1153.3, -667.71, -805.79, 91.856
         917.14, -882.75, -810.95, 663.88, 4.4344];
    C = P5Pfr(u,X,struct('type','KRCrd'));
    e = PerspRadDivRepErr(C,[a2h(u);X]);    
    Cm(2) = abs(C{2}.K(1,1)-1000)<0.2 && abs(C{2}.r-(-1e-1))<1e-4 && max(e(2,:))<0.2;   
    % test 3 f = 10 r = [-1e-1 -1e-2 -1e-3]
    u = [7.4269, 11.096, -6.5996, -7.9665, 0.91856, 
         9.0017, -8.4931, -8.0154, 6.5635, 0.044344];
    C = P5Pfr(u,X,struct('type','KRCrd','r',[0 0 0]));
    Cm(3) = abs(C{2}.K(1,1)-10)<0.02 && abs(C{2}.r(1)-(-1e-1))<2e-3 && abs(C{2}.r(2)-(-1e-2))<6e-4 && abs(C{2}.r(3)-(-1e-3))<1e-4;
    % test 4 two parameters of the distortion f = 1000 r = [-1e-1 -1e-2]
    u = [744.26, 1116.0, -660.68, -797.50, 91.856
         902.08, -854.15, -802.42, 657.05, 4.4344];
    C = P5Pfr(u,X,struct('type','KRCrd','r',[0 0]));
    Cm(4) = abs(C{2}.K(1,1)-1000)<3 && all(abs(C{2}.r-[-1e-1;-1e-2])<1e-3);    
    % test 5 all simulated in Matlab
    X = [-0.0478   -0.5662   -0.3109   -0.1337   -0.0122
         -0.0839   -0.0394    0.2115    0.2512    0.1024
          2.9754    2.7150    2.7436    2.8528    2.9096]*100;
    C0.type = 'KRCrd'; C0.K = diag([3755.3 3755.3 1]);
    C0.R = [ -0.018016107077031   0.982231955744260  -0.186804188926789
              0.886146245888689   0.102215095286981   0.451992151693873
              0.463055343110488  -0.157392691730861  -0.872242678276260];
    C0.C = [  -77
               24
              389]; 
    C0.r = -0.019151497369414;
    u = X2u(X,C0);
    C = P5Pfr(u,X,struct('type','KRCrd','r',[0]));
    e = PerspRadDivRepErr(C,[a2h(u);X]);
    Cm(5) = abs(C{3}.K(1,1)-C0.K(1,1))<2e-5 && abs(C{3}.r-C0.r)<1e-8 && max(e(3,:))<1e-6;
    % test 6 real data with small radial distortion
    u = [-0.5023   -0.1816    0.5608    0.6180    0.1138
          0.6223   -1.2260   -0.3493    0.3088    0.6635]*1000;
    X = [-0.0478   -0.5662   -0.3109   -0.1337   -0.0122
         -0.0839   -0.0394    0.2115    0.2512    0.1024
          2.9754    2.7150    2.7436    2.8528    2.9096]*100;
    C = P5Pfr(u,X,struct('type','KRCrd','r',[0]));
    e = PerspRadDivRepErr(C,[a2h(u);X]);
    P = P4ptP4Pf([a2h(u(:,2:5));X(:,2:5)]); 
    for i=1:numel(P)
        [C4{i}.K,C4{i}.R,C4{i}.C]=P2KRC(P{i});
    end
    Cm(6) = max([abs(C{3}.K(:)-C4{3}.K(:))])/C4{3}.K(1,1) < 0.03 && ... 
            180*acos((trace(C{3}.R\C4{3}.R)-1)/2)/pi < 0.4 && ...
            vnorm(C{3}.C-C4{3}.C)/vnorm(C4{3}.C) < 0.007;
end
