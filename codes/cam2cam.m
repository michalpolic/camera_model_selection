function w = cam2cam(F, v, u)
    ls =  F * [v; ones(1, size(v, 2))];

    ay = ls(1, :) .* u(2, :);
    bx = ls(2, :) .* u(1, :);
    ac = ls(1, :) .* ls(3, :);
    bc = ls(2, :) .* ls(3, :);

    dd = ls(1, :).^2 + ls(2, :).^2;

    w = [(ls(2, :) .* (bx - ay) - ac) ./ dd; ...
         (ls(1, :) .* (ay - bx) - bc) ./ dd];
end