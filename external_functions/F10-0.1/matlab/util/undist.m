function [outim, K2] = undist(im, K, lambda, scale, crop)

if (nargin < 5)
    crop = 1;
end

if (nargin < 4)
    scale = 1;
end

[h, w, ~] = size(im);

bbox = [   1   1   1;
         w/2   1   1;
           w   1   1;
           w h/2   1;
           w   h   1;
         w/2   h   1;
           1   h   1;
           1 h/2   1;
           1   1   1]';  

ubbox = im2uim(bbox, K, lambda);
        
x1 = min(ubbox(1,:));
x2 = max(ubbox(1,:));
y1 = min(ubbox(2,:));
y2 = max(ubbox(2,:));

W = (x2 - x1) * crop;
H = (y2 - y1) * crop;

if ((W > 7000) || (H > 7000))
    disp([W H]);
    warning('Image would be too big, bailing out');
    outim = [];
    K2 = [];
    return;
end

H = ceil(H * scale);
W = ceil(W * scale);

K2 = [K(1,1) * scale, 0, W/2; 0, K(2,2) * scale, H/2; 0, 0, 1];

[X, Y] = meshgrid(1:W,1:H);

Z = [X(:)'; Y(:)'];
Z = uim2im(Z, K2, lambda, K);

X = reshape(Z(1,:), H, W);
Y = reshape(Z(2,:), H, W);

outim = vl_imwbackward(im2double(im),X,Y);
end

function Z = im2uim(X, K, l)
    Y = im2cam(X, K, l);
    Z = cam2im(Y, K);
end

function Z = uim2im(X, K, l, K2)
    Y = im2cam(X, K);
    
    if (nargin > 3)
        Z = cam2im(Y, K2, l);
    else
        Z = cam2im(Y, K, l);
    end
end
