function dts = matcher(im1, im2, params)
% Demonstrator of the epipolar geometry solvers presented in
% Zuzana Kukelova, Jan Heller, Martin Bujnak, Andrew Fitzgibbon, Tomas Pajdla: 
% Efficient Solution to the Epipolar Geometry for Radially Distorted Cameras, 
% The IEEE International Conference on Computer Vision (ICCV),
% December, 2015, Santiago, Chile.
%
% 2015, Jan Heller, hellej1@cmp.felk.cvut.cz

% SIFT detection and prematching ==========================================

fprintf('Detecting SIFT ... ');
im1 = im2single(im1);
if (size(im1, 3) > 1)
    im1 = rgb2gray(im1);
end
[dts.pts1, dts.desc1] = vl_sift(im1);
fprintf('%d keypoints detected\n', size(dts.pts1, 2));

fprintf('Detecting SIFT ... ');
im2 = im2single(im2);
if (size(im2, 3) > 1)
    im2 = rgb2gray(im2);
end
[dts.pts2, dts.desc2] = vl_sift(im2);
fprintf('%d keypoints detected\n', size(dts.pts2, 2));

% SIFT prematching
fprintf('Prematching SIFT ... ');
dts.matches = vl_ubcmatch(dts.desc1, dts.desc2, params.match_threshold);
fprintf('%d matches\n', size(dts.matches, 2));

[h, w, ~] = size(im1);
f = max(h, w);
dts.K1 = [f, 0, w/2; 0, f, h/2; 0 0 1];

[h, w, ~] = size(im2);
f = max(h, w);
dts.K2 = [f, 0, w/2; 0, f, h/2; 0 0 1];