function [txt_out] = highlight_b12(score, sorted_arr)
    txt_out = sprintf('%.1f',100*score);
    if score == sorted_arr(1)
        txt_out = sprintf('\\X{%s}',txt_out);
    end
    if score == sorted_arr(2)
        txt_out = sprintf('\\Y{%s}',txt_out);
    end
end

