function [ w_err ] = huber_penalty( err, alpha )
%HUBER_PENALTY - apply Huber penalty function with given threshold
    w_err = zeros(size(err));
    s1 = abs(err) < alpha;
    w_err(s1) = (err(s1).^2) ./ 2;
    w_err(~s1) = alpha*(abs(err(~s1))-0.5*alpha);
end

