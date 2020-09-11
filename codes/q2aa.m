function [ aa ] = q2aa( q )
%Q2AA - compute angle axix for rotation matrix
    sinth = sqrt(q(2:end)' * q(2:end));
    angle = 2 * atan2(sinth, q(1));
    aa = (angle/sinth) * q(2:end);
end

