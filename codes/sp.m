function [ str2 ] = sp( str, l, loc )
%SP - add spaces before string to make unique offset
    N = l-length(str);
    if N < 0
        N = 6;
        %warning('offset is too small'); 
    end
    if exist('loc','var') 
        switch loc
            case 'B' % behind
                str2 = sprintf('%s%s',str, repmat(' ',1,N));
            case 'I' % in front of
                str2 = sprintf('%s%s',repmat(' ',1,N),str);
            otherwise   % in front of
                str2 = sprintf('%s%s',repmat(' ',1,N),str);
        end
    else     % in front of
        str2 = sprintf('%s%s',repmat(' ',1,N),str);
    end
end

