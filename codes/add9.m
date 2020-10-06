function [ ngraph ] = add9( ngraph, number )
    ngraph = mod(ngraph+number-1,9)+1;
end

