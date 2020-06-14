function [model_id] = model2model_id(model)
    
    str_models = {'SIMPLE_PINHOLE','PINHOLE','SIMPLE_RADIAL','RADIAL',...
        'OPENCV','OPENCV_FISHEYE','FULL_OPENCV','FOV','SIMPLE_RADIAL_FISHEYE',...
        'RADIAL_FISHEYE','THIN_PRISM_FISHEYE','RADIAL3','RADIAL4',...
        'RADIAL3_DIVISION1','RADIAL3_DIVISION2','RADIAL3_DIVISION3',...
        'RADIAL1_DIVISION1','RADIAL2_DIVISION2'};

    model_id = find(arrayfun(@(i) strcmp(model,str_models{i}), 1:length(str_models)));
    
    if ~isempty(model_id)
        model_id = model_id - 1;
    else
        error('unknown camera model');
    end
    
end

