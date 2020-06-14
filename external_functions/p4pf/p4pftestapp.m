% P4P + unknown focal length testing app
% given a set of 4x 2D<->3D correspondences, calculate camera pose and the 
% camera focal length.
%
% by Martin Bujnak, (c)apr2008
%


% ground truth focal, image resolution [-0.5;0.5]x[-0.5;0.5]
fgt = 1.5;

% 4x 2D - 3D correspondences
if 0

    % planar
    M = [ -4.16909046323065 -21.76924382754407 -11.28160103570576  -18.70673643641682
           8.76573361388879   2.54916911753407 -15.64179144355760   -7.12884738225938
                          0                  0                  0                   0];
          
    m =  [ -0.01685480263817  -0.30156127000652  -0.11261034380081    -0.25658711285962
           -0.05066846248374   0.01061608945225   0.17825476446826     0.09480347286640];
       
    % ground truth orientation + position
    Rgt = [  0.99441452977752  -0.10554498077766                  0
            -0.05095105295313  -0.48004620390991  -0.87576231496602
             0.09243231669889   0.87087077063381  -0.48274254803710];
        
    Tgt = [  3.98991000654439;  0.74564356260581;  88.96209555860348];
    
else
    
    % general scene
    M =  [ -3.33639834336120 -23.35549638285873 -13.18941519576778  6.43164913914748 
            0.65948286155096  -4.90376715918747   1.17103701629876  0.14580433383203
           -8.46658219501120  -3.99876939947909  -3.02248927651177  -22.16086539862748];

    m = [ 0.11009888473695   0.39776592879400   0.28752996253253   -0.05017617729940
          0.03882059658299  -0.17303453640632  -0.05791310109713    0.19297848817239];
         
    % ground truth orientation + position
    Rgt = [ -0.94382954756954   0.33043272406750                  0
             0.27314119331857   0.78018522420862  -0.56276540799790
            -0.18595610677571  -0.53115462041845  -0.82661665574857];
    
    Tgt = [ 2.85817409844554; -2.17296255562889; 77.54246130780075];
end

display 'pure Matlab version ----'

tic
[f R t] = P4Pf_m(m, M);
toc

% solutions test
for i=1:length(f)

    Rrel = inv(Rgt)*R(:,:,i);
    Trel = Tgt - t(:,i);
    dangle = norm(acos( ( trace(Rrel) - 1 ) / 2 ))  / pi * 180;

    % print errors
    fprintf('focal err:%d   rotation err:%d   translation err:%d\n',(fgt-f(i)), dangle, norm(Trel));
end


display 'mex-Matlab version ----'

% type "mex p4pfmex.c" to compile mex helper file
tic
[f R t] = P4Pf(m, M);
toc

% solutions test
for i=1:length(f)

    Rrel = inv(Rgt)*R(:,:,i);
    Trel = Tgt - t(:,i);
    dangle = norm(acos( ( trace(Rrel) - 1 ) / 2 ))  / pi * 180;

    % print errors
    fprintf('focal err:%d   rotation err:%d   translation err:%d\n',(fgt-f(i)), dangle, norm(Trel));
end