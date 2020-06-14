% Demonstrator of the epipolar geometry solvers presented in
% Zuzana Kukelova, Jan Heller, Martin Bujnak, Andrew Fitzgibbon, Tomas Pajdla: 
% Efficient Solution to the Epipolar Geometry for Radially Distorted Cameras, 
% The IEEE International Conference on Computer Vision (ICCV),
% December, 2015, Santiago, Chile.
%
% 2015, Jan Heller, hellej1@cmp.felk.cvut.cz

function method = getmethod_F10e
    method.name = 'F10e';
    method.min_points = 10;
    method.get_model = @get_model_F10e;

    function model = get_model_F10e(x, u)
        % function returns F,l1, l2, such that
        %
        %   xx = im2cam(x, eye(3), l1);
        %   uu = im2cam(u, eye(3), l2);
        %   er = sum([xx; ones(1,10)] .* (F * [uu; ones(1,10)]))
        %
        % where er is a zero vector. That is
        %
        % x(l1)' * F * u(l2) = 0
        
        [Fs, ls] = f10e_mex(x', u');
        
        no_models = size(Fs, 2);
        model = cell(1, no_models);
        for i = 1:no_models
            model{i}.F = reshape(Fs(:, i), 3, 3);
            model{i}.l1 = ls(1, i);
            model{i}.l2 = ls(2, i);
        end            
    end
end
