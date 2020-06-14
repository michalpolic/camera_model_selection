% Demonstrator of the epipolar geometry solvers presented in
% Zuzana Kukelova, Jan Heller, Martin Bujnak, Andrew Fitzgibbon, Tomas Pajdla: 
% Efficient Solution to the Epipolar Geometry for Radially Distorted Cameras, 
% The IEEE International Conference on Computer Vision (ICCV),
% December, 2015, Santiago, Chile.
%
% 2015, Jan Heller, hellej1@cmp.felk.cvut.cz
%
% This demo does a simple fundamental matrix/radial distortion recovery based on SIFT
% detection/prematching (VLFeat library), followed by a simple RANSAC loop
% where F10 algorithm is used. No local nonlinear refinement is
% performed afterwards.

[root, ~, ~] = fileparts(mfilename('fullpath'));

addpath(fullfile(root, 'vl'));
addpath(fullfile(root, 'util'));

bindir = mexext;
if strcmp(bindir, 'dll')
    bindir = 'mexw32' ; 
end
addpath(fullfile(root, 'vl', bindir)) ;

% Load images
impath1 = ['..' filesep 'data' filesep 'GOPR0175.JPG'];
impath2 = ['..' filesep 'data' filesep 'GOPR0182.JPG'];

fprintf('Loading image %s ... ', impath1);
im1 = imread(impath1);
fprintf('done\n');

fprintf('Loading image %s ... ', impath2);
im2 = imread(impath2);
fprintf('done\n');

% Setup parameters
params.ransac_iters = 1000;
params.ransac_threshold = 3;
params.match_threshold = 1.5;
params.lmax = 2;
params.lmin = -10;

% SIFT detection and matching
dts = matcher(im1, im2, params);

% Fundamental matrix + radial distortion using F10e method
params.method = getmethod_F10e;
modelF10e = ransac(dts, params);

% Radial distortion visualization
showmatches(im1, im2, dts, modelF10e, params.method.name);

fprintf('Undistorting image %s ... ', impath1);
uim1 = undist(im1, dts.K1, modelF10e.geom.l1, 0.3, 1);
fprintf('done\n');

fprintf('Undistorting image %s ... ', impath2);
uim2 = undist(im2, dts.K2, modelF10e.geom.l2, 0.3, 1);
fprintf('done\n');

dh1 = max(size(uim2,1) - size(uim1,1),0);
dh2 = max(size(uim1,1) - size(uim2,1),0);
figure;
imshow([padarray(uim1, dh1,'post') padarray(uim2, dh2,'post')]);
