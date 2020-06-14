function [ new_str ] = strrep_( orig_str, new_var )
%STRREP_ - replace "_" by new variable

    if iscell(orig_str)
        new_str = cell(size(orig_str,1), size(orig_str,2));
        for i = 1:size(orig_str,1)
            for j = 1:size(orig_str,2)
                new_str{i,j} = strrep(orig_str{i,j},'_',new_var);
            end
        end
        return;
    end

    new_str = strrep(orig_str,'_',new_var);

end

