% N = nulld(A,d) - The basis of the most singular right space of A with dimension d
% 
% A = real matrix
% N = "null space", i.e. A*N ~ 0 with size(N,2)=d
%
% [~,~,N]=svd(A); N = N(:,end-d+1:end);

% 2017-04-01, pajdla@cvut.cz
function N = nulld(A,d)
if nargin<2
    N = null(A);
else
    [~,~,N] = svd(A);
    N = N(:,end-d+1:end);
end
