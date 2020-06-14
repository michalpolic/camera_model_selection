function [res] = eval_acc(res, scene, setting)
%EVAL_ACC - evaluate the ACC algorithm for given thresholds

    loc_res = struct();

    % evaluation with selected reprojection error 
    for j = 1:length(setting.reproj_threshold)
        fprintf('  > eval max. reproj. err: %.5f\n', setting.reproj_threshold(j))
        loc_d = subscene_Se( clone_scene(scene), setting.reproj_threshold(j) );
        loc_res.(sprintf('ACC_%02d',round(10*setting.reproj_threshold(j)))) = accuracy_of_pair(loc_d);
    end
   res.ACC = loc_res;
end

