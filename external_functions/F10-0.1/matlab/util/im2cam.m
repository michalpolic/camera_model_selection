function Z = im2cam(X, K, l)
    if (size(X, 1) == 2)
        X = [X; ones(1, size(X, 2))];
    end
    
    Y = K \ X;
    
    if (nargin > 2)
        R = 1 + l * (Y(1,:).^2 + Y(2,:).^2);
        Z = Y(1:2,:) ./ ([1; 1] * R);
    else
        Z = Y(1:2,:);
    end
end