function [ r ] = iDiv3toDiv3( k1, k2, k3, s )
%IDIV3TODIV3 - computes the distance from center for forward division model
%from inverse division model
    r = cell2mat(arrayfun(@(i) eig(compan([k3 0 k2 0 k1 1/s(2) 1])), 1:size(s,2), 'UniformOutput', false));  
end
