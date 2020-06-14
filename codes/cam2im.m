function Z = cam2im(X, K, l)        
    if ((nargin > 2) && (l ~= 0))
        Xd = 1/2 * X(1,:) ./ (l*X(2,:).^2 + l*X(1,:).^2) .* (1 - (1 - 4*l*X(2,:).^2 - 4*l*X(1,:).^2).^(1/2));
        Yd = 1/2 ./ (l*X(2,:).^2 + l*X(1,:).^2) .* (1 - (1 - 4*l*X(2,:).^2 - 4*l*X(1,:).^2).^(1/2)) .* X(2,:);

        Y = [real(Xd); real(Yd); ones(1, size(X, 2))];
        
        Y(1,isnan(Y(1,:))) = X(1,isnan(Y(1,:)));
        Y(2,isnan(Y(2,:))) = X(2,isnan(Y(2,:)));
    else
        if (size(X, 1) == 2)
          Y = [X; ones(1, size(X, 2))];
        else
          Y = X;
        end
    end
    
    Z = K * Y;
    Z = Z(1:2,:) ./ ([1; 1] * Z(3,:));
end