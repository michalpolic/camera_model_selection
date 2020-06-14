function showmatches(im1, im2, dts, model, mname)

f1 = dts.pts1;
f2 = dts.pts2;
mt = dts.matches;

dh1 = max(size(im2,1)-size(im1,1),0) ;
dh2 = max(size(im1,1)-size(im2,1),0) ;

figure;
subplot(2,1,1);

imagesc([padarray(im1, dh1,'post') padarray(im2, dh2,'post')]);
o = size(im1, 2);
line([f1(1, mt(1,:)); f2(1, mt(2, :)) + o], ...
    [f1(2, mt(1,:)); f2(2, mt(2, :))]);
title(sprintf('%d tentative matches', size(mt, 2)));
axis image off;

cset = model.cset;
subplot(2,1,2);
imagesc([padarray(im1, dh1, 'post') padarray(im2, dh2, 'post')]);
line([f1(1, mt(1, cset));f2(1, mt(2, cset)) + o], ...
    [f1(2, mt(1,cset));f2(2, mt(2,cset))]);
title(sprintf('%s: %d (%.2f%%) inliner matches out of %d', ...
    mname, ...
    sum(cset), ...
    100*sum(cset)/size(mt, 2), ...
    size(mt, 2)));
axis image off;