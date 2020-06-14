% n = vnorm(x) - columnwise vector 2 norm
% 
% n = sqrt(sum(x.^2))

% (c) T.Pajdla, 2006-05-02
function n = vnorm(x)
    n = sqrt(sum(x.^2));
return
