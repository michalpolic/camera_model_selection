function errs = model_errors(x_i, u_i, model, K1, K2)
% x_i: correspondences in 1. image coordinate system
% u_i: correspondences in 2. image coordinate system

x_c = im2cam(x_i, K1, model.l1); % x_i to 1. camera coordinate system
u_c = im2cam(u_i, K2, model.l2); % u_i to 2. camera coordinate system

ut_c = cam2cam(model.F, u_c, x_c); % u_c to 1. camera coordinate system as a point on the epipolar line closest to x_c
xt_c = cam2cam(model.F', x_c, u_c); % x_c to 2. camera coordinate system as a point on the epipolar line closest to u_c

ut_i = cam2im(ut_c, K1, model.l1); % ut_c to 1. image coordinate system
xt_i = cam2im(xt_c, K2, model.l2); % xt_c to 2. image coordinate system

% Model errors as the symmetric transfer error
errs = 0.5 * (sum((x_i - ut_i).^2) + sum((u_i - xt_i).^2));
end
