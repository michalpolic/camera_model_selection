function [ h ] = plotCov( C, X, show_edges, color )
% plotCov - plot the covariance matrix C [3x3] with mean in X [3x1] 
    h = [];
    if isnan(sum(sum(C))) || isinf(sum(sum(C)))
        return;
    end

    [V,e] = eig(full(C));
%     if ~isreal(V)
%         V = real(V);
%         e = real(e);
%         A = real(V*sqrt(e));
%     else
        A = V*sqrt(e);
%     end

    if isreal(A)
        K = 30;
        [x,y,z]=sphere(K);
        XYZ = (3*A)*[x(:) y(:) z(:)]';
        x = reshape(XYZ(1,:),K+1,K+1) + X(1);
        y = reshape(XYZ(2,:),K+1,K+1) + X(2);
        z = reshape(XYZ(3,:),K+1,K+1) + X(3);
        if (nargin > 2 & show_edges)
            h = surf(x,y,z);
        else
            h = surf(x,y,z,'EdgeColor','none');
        end
        if (nargin > 3 & ~isempty(color))
            set(h,'FaceColor',color,'FaceAlpha',1); % 0.2
        else
            set(h,'FaceColor',[1 1 0],'FaceAlpha',1); % 0.2
        end
    end
end
