function [ r ] = iDiv4toDiv4( k1, k2, k3, k4, s )
%IDIV4TODIV4 - computes the distance from center for forward division model
%from inverse division model
    r = cell2mat(arrayfun(@(i) eig(compan([k4 0 k3 0 k2 0 k1 1/s(2) 1])), 1:size(s,2), 'UniformOutput', false));  
end