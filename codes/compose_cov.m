function [ cov_xys, Sigma_u ] = compose_cov( cov_xys_imgs )
%COMPOSE_COV Summary of this function goes here
%   Detailed explanation goes here

    % all the covariances in one array
    cov_xys = cell2mat(cov_xys_imgs');
    
    % rewrite the covariances into the matrix
    N = size(cov_xys,2);
    Sigma_u = sparse(2*N,2*N);
    for i = 1:N
        C_i = reshape(cov_xys(:,i),2,2);
        if sum(sum(abs(C_i))) == 0
            Sigma_u(2*i-1:2*i, 2*i-1:2*i) = eye(2);
        else
            Sigma_u(2*i-1:2*i, 2*i-1:2*i) = sparse(inv(C_i));
        end
    end   
end

