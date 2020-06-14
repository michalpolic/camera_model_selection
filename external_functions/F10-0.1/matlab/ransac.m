function [model, params] = ransac(dts, params)
% Demonstrator of the epipolar geometry solvers presented in
% Zuzana Kukelova, Jan Heller, Martin Bujnak, Andrew Fitzgibbon, Tomas Pajdla: 
% Efficient Solution to the Epipolar Geometry for Radially Distorted Cameras, 
% The IEEE International Conference on Computer Vision (ICCV),
% December, 2015, Santiago, Chile.
%
% 2015, Jan Heller, hellej1@cmp.felk.cvut.cz

% RANSAC ==================================================================
% Here, we will assume the center of radial distortion to be in the center
% of the image. Also, we will scale the detections to the [-1,1]^2 rectangle
  
X1i = dts.pts1(1:2, dts.matches(1,:));
X2i = dts.pts2(1:2, dts.matches(2,:));
    
X1c = im2cam(X1i, dts.K1);
X2c = im2cam(X2i, dts.K2);    

no_matches = size(dts.matches, 2);
params.max_score = 0;

fprintf('Running %d RANSAC iterations using method %s ... \n', ...
    params.ransac_iters, params.method.name);

% define local optimization function
fres = @(F,l1,l2,u1,u2) arrayfun(@(k) ...
    [u1(:,k); 1 + l1*sum(u1(:,k).^2)]' * F * [u2(:,k); 1 + l2*sum(u2(:,k).^2)],1:size(u1,2));

% define SPRT threshold
params.decision_threshold_sprt = designSPRTTest(params);

for t = 1:params.ransac_iters
    subset = vl_colsubset(1:no_matches, params.method.min_points);
    models = params.method.get_model(X1c(:, subset), X2c(:, subset));
    
    for i = 1:numel(models)
        if (models{i}.l1 < params.lmin || models{i}.l1 > params.lmax || ...
            models{i}.l2 < params.lmin || models{i}.l2 > params.lmax)
            continue;
        end

        if ~params.use_SPRT
            errs = model_errors(X1i, X2i, models{i}, dts.K1, dts.K2);
            cset = errs < params.ransac_threshold;
            score = sum(cset);
        else
% %             % Matlab version
%             [model_rejected, errs, score, params] = model_errors_sprt(X1i, X2i, models{i}, dts.K1, dts.K2, params);
%             f10eval(int32(size(X1i,2)), params.ransac_threshold, params.sprt_delta, params.sprt_epsilon, ...
%                 params.decision_threshold_sprt, X1i, X2i, models{i}.F, models{i}.l1, models{i}.l2, dts.K1, dts.K2);
            
            % Cpp version
            [model_rejected, errs, score] = f10eval(int32(size(X1i,2)), params.ransac_threshold, params.sprt_delta, params.sprt_epsilon, ...
                                                params.decision_threshold_sprt, X1i, X2i, models{i}.F, models{i}.l1, models{i}.l2, dts.K1, dts.K2);
            score = double(score);
            if model_rejected
                continue;
            end
        end
        
        while (params.max_score < score)
            fprintf('  Bigger CS found: %d (%d, %.2f%%), it. %d/%d \n', ... 
            score, no_matches, score / no_matches * 100, t, params.ransac_iters);
            model.geom = models{i};
            model.score = score;
            model.cset = errs < params.ransac_threshold;
            params.max_score = score;
            
            % loacal optimization
            u1 = X1c(:,model.cset);
            u2 = X2c(:,model.cset);
            fun = @(X) sum(fres([X(1) X(2) X(3); X(4) X(5) X(6); X(7) X(8) X(9)]', X(10), X(11), u1, u2).^2);
            options=optimset('disp','off','MaxIter',10);
            [x,~] = fminunc(fun, [models{i}.F(:); models{i}.l1; models{i}.l2], options);    
            models{i}.F = [x(1) x(2) x(3); x(4) x(5) x(6); x(7) x(8) x(9)]';
            models{i}.l1 = x(10);
            models{i}.l2 = x(11);
            
            if ~params.use_SPRT
                errs = model_errors(X1i, X2i, models{i}, dts.K1, dts.K2);
                cset = errs < params.ransac_threshold;
                score = sum(cset);
            else
%                 [~, ~, score, params] = model_errors_sprt(X1i, X2i, models{i}, dts.K1, dts.K2, params);
                [~, ~, score] = f10eval(int32(size(X1i,2)), params.ransac_threshold, params.sprt_delta, params.sprt_epsilon, ...
                                                params.decision_threshold_sprt, X1i, X2i, models{i}.F, models{i}.l1, models{i}.l2, dts.K1, dts.K2);
            end
        end
    end
end