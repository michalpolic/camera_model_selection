function [ w_err ] = talwar_penalty( err, alpha )
%TALWAR_PENALTY - apply Talwar penalty function with given threshold
    w_err = zeros(size(err));
    s1 = abs(err) < alpha;
    w_err(s1) = (err(s1).^2) ./ 2;
    w_err(~s1) = (alpha^2) / 2;
end

