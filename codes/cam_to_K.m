function K = cam_to_K( cam )
%CAM_TO_K - compose K
    
    p = cam.params;
    switch cam.model
        case 'SIMPLE_PINHOLE'       % f, cx, cy
            K = [p(1) 0 p(2); 0 p(1) p(3); 0 0 1];
        case 'PINHOLE'              % fx, fy, cx, cy
            K = [p(1) 0 p(3); 0 p(2) p(4); 0 0 1];    
        case 'SIMPLE_RADIAL'        % f, cx, cy, k1
            K = [p(1) 0 p(2); 0 p(1) p(3); 0 0 1];
        case 'RADIAL'               % f, cx, cy, k1, k2
            K = [p(1) 0 p(2); 0 p(1) p(3); 0 0 1];
        case 'SIMPLE_RADIAL_FISHEYE'% f, cx, cy, k1
            K = [p(1) 0 p(2); 0 p(1) p(3); 0 0 1];
        case 'RADIAL_FISHEYE'       % f, cx, cy, k1, k2
            K = [p(1) 0 p(2); 0 p(1) p(3); 0 0 1];
        case 'RADIAL3'              % f, cx, cy, k1, k2, k3
            K = [p(1) 0 p(2); 0 p(1) p(3); 0 0 1];
        case 'RADIAL4'              % f, cx, cy, k1, k2, k3, k4
            K = [p(1) 0 p(2); 0 p(1) p(3); 0 0 1];
        case 'OPENCV'               % fx, fy, cx, cy, k1, k2, p1, p2
        	K = [p(1) 0 p(3); 0 p(2) p(4); 0 0 1];    
        case 'OPENCV_FISHEYE'     	% fx, fy, cx, cy, k1, k2, k3, k4
        	K = [p(1) 0 p(3); 0 p(2) p(4); 0 0 1];    
        case 'FULL_OPENCV'          % fx, fy, cx, cy, k1, k2, p1, p2, k3, k4, k5, k6   
        	K = [p(1) 0 p(3); 0 p(2) p(4); 0 0 1];    
            
        case 'DIVISION_1'            % f, cx, cy, l1
            K = [p(1) 0 p(2); 0 p(1) p(3); 0 0 1];
        case 'DIVISION_2'            % f, cx, cy, l1, l2
            K = [p(1) 0 p(2); 0 p(1) p(3); 0 0 1];
        case 'DIVISION_3'            % f, cx, cy, l1, l2 ,l3
            K = [p(1) 0 p(2); 0 p(1) p(3); 0 0 1];
        case 'DIVISION_4'           % f, cx, cy, l1, l2, l3, l4
           K = [p(1) 0 p(2); 0 p(1) p(3); 0 0 1];    
        
        case 'IDIVISION_1'            % f, cx, cy, l1
            K = [p(1) 0 p(2); 0 p(1) p(3); 0 0 1];
        case 'IDIVISION_2'            % f, cx, cy, l1, l2
            K = [p(1) 0 p(2); 0 p(1) p(3); 0 0 1];
        case 'IDIVISION_3'            % f, cx, cy, l1, l2, l3
            K = [p(1) 0 p(2); 0 p(1) p(3); 0 0 1];
        case 'IDIVISION_4'            % f, cx, cy, l1, l2, l3, l4
            K = [p(1) 0 p(2); 0 p(1) p(3); 0 0 1];
            
       otherwise
            error('The transform. to K is not implemented.');
    end

end

