function [ filter ] = filter_field_of_view( u, cam )
%FILTER_FIELD_OF_VIEW - find the filter for observations in specified field
%of view
    wrong = (u(:,1) <= 0) | (u(:,2) <= 0) | (u(:,1) >= cam.width) |  (u(:,2) >= cam.height);
    filter = ~wrong;
end

