function errs = radhomo_errors(x, u, model, K1, K2)

v = im2cam(u, K2, model.l2);
v = cam2cam(v, model.H);
v = cam2im(v, K1, model.l1);

d = v - x;

errs = sqrt(sum(d.^2));

v = im2cam(x, K1, model.l1);
v = cam2cam(v, inv(model.H));
v = cam2im(v, K2, model.l2);

d = v - u;

errs = (errs + sqrt(sum(d.^2))) / 2;
end
