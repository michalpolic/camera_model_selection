function [ cam ] = extend_camera_model( cam, new_model )
%EXTEND_CAMERA_MODEL - create extended camera model with more parameters
%(i.e. RADIAL model)
    
    % setup new model if unknown
    if ~exist('new_model','var')
    	new_model = 'RADIAL';
    elseif new_model == -1          % add aprox. one parameter
        new_model = next_model( cam.model );
    end 
    

    % TODO ALL MODELS ... we assume f, fx, fy, cx, cy, p1, p2, k1, k2, k3, k4, k5, k6, q1, q2 parameters now
    k1 = 0;
    k2 = 0;
    k3 = 0;
    k4 = 0;
    k5 = 0;
    k6 = 0;
    p1 = 0;
    p2 = 0;
    q1 = 0;
    q2 = 0;
    
    switch cam.model
        case 'SIMPLE_PINHOLE'
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
        case 'PINHOLE'
            f = (cam.params(1) + cam.params(2))/2;
            fx = cam.params(1);
            fy = cam.params(2);
            cx = cam.params(3);
            cy = cam.params(4);
        case 'SIMPLE_RADIAL'
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
            k1 = cam.params(4);
        case 'RADIAL'
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
            k1 = cam.params(4);
            k2 = cam.params(5);
        case 'SIMPLE_RADIAL_FISHEYE'        
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
            q1 = cam.params(4);
        case 'RADIAL_FISHEYE'
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
            q1 = cam.params(4);
            q2 = cam.params(5);
       case 'RADIAL3'
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
            k1 = cam.params(4);
            k2 = cam.params(5);
            k3 = cam.params(6);
        case 'RADIAL4'  
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
            k1 = cam.params(4);
            k2 = cam.params(5);
            k3 = cam.params(6);
            k4 = cam.params(7);
        case 'DIVISION1'  
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
%             k1 = cam.params(4);
        case 'DIVISION2'  
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
%             k1 = cam.params(4);
%             k2 = cam.params(5);
        case 'DIVISION3'  
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
        case 'DIVISION4'  
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
        case 'RADIAL3_DIVISION1'
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
        case 'RADIAL3_DIVISION2'
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
      	case 'RADIAL3_DIVISION3'
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
        case 'RADIAL1_DIVISION1'
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
        case 'RADIAL2_DIVISION2'
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
        case 'I_DIVISION1'
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
        case 'I_DIVISION2'
            f = cam.params(1);
            fx = cam.params(1);
            fy = cam.params(1);
            cx = cam.params(2);
            cy = cam.params(3);
        case 'OPENCV'               % fx, fy, cx, cy, k1, k2, p1, p2
            f = (cam.params(1) + cam.params(2)) / 2;
            fx = cam.params(1);
            fy = cam.params(2);
            cx = cam.params(3);
            cy = cam.params(4);
            k1 = cam.params(5);
            k2 = cam.params(6);
            p1 = cam.params(7);
            p2 = cam.params(8);
        case 'OPENCV_FISHEYE'       % fx, fy, cx, cy, k1, k2, k3, k4
            f = (cam.params(1) + cam.params(2)) / 2;
            fx = cam.params(1);
            fy = cam.params(2);
            cx = cam.params(3);
            cy = cam.params(4);
%             k1 = cam.params(5);
%             k2 = cam.params(6);
%             k3 = cam.params(7);
%             k4 = cam.params(8);
        case 'FULL_OPENCV'          % fx, fy, cx, cy, k1, k2, p1, p2, k3, k4, k5, k6
            f = (cam.params(1) + cam.params(2)) / 2;
            fx = cam.params(1);
            fy = cam.params(2);
            cx = cam.params(3);
            cy = cam.params(4);
            k1 = cam.params(5);
            k2 = cam.params(6);
            p1 = cam.params(7);
            p2 = cam.params(8);
            k3 = cam.params(9);
%             k4 = cam.params(10);
%             k5 = cam.params(11);
%             k6 = cam.params(12);
        otherwise
            error('Unknown input camera model!');
    end
    
    % MAPPING BROWN -> FISHEYE
%     if (q1 == 0)
%         r = linspace(0.01,1,100);
%         q1 = median((1 + k1*r.^2 + k2*r.^4 + k3*r.^6 + k4*r.^8 - atan(r)) ./ atan(r).^3);
%         q2 = median((1 + k1*r.^2 + k2*r.^4 + k3*r.^6 + k4*r.^8 - atan(r) - q1.*atan(r).^3) ./ atan(r).^5);
%     end
    
    
    % set new camera properties
    cam.model = new_model;
    switch cam.model
        case 'SIMPLE_PINHOLE'
            cam.params = [f, cx, cy]';
        case 'PINHOLE'
            cam.params = [fx, fy, cx, cy]';
        case 'SIMPLE_RADIAL'
            cam.params = [f, cx, cy, k1]';
        case 'RADIAL'
            cam.params = [f, cx, cy, k1, k2]';
        case 'DIVISION1'     
            cam.params = [f, cx, cy, 0]';
        case 'DIVISION2'      
            cam.params = [f, cx, cy, 0, 0]';
        case 'DIVISION3'     
            cam.params = [f, cx, cy, 0, 0, 0]';
        case 'DIVISION4'      
            cam.params = [f, cx, cy, 0, 0, 0, 0]';
        case 'I_DIVISION1'
            cam.params = [f, cx, cy, 0.01]';
        case 'I_DIVISION2'
            cam.params = [f, cx, cy, 0.01, 0.001]';   
        case 'SIMPLE_RADIAL_FISHEYE'
            cam.params = [f, cx, cy, q1]';
        case 'RADIAL_FISHEYE'
            cam.params = [f, cx, cy, q1, q2]';
        case 'RADIAL3'
            cam.params = [f, cx, cy, k1, k2, k3]';
        case 'RADIAL4'  
            cam.params = [f, cx, cy, k1, k2, k3, k4]';
        case 'RADIAL3_DIVISION1'  
            cam.params = [f, cx, cy, k1, k2, k3, 0]';
        case 'RADIAL3_DIVISION2'  
            cam.params = [f, cx, cy, k1, k2, k3, 0, 0]';
        case 'RADIAL3_DIVISION3'  
            cam.params = [f, cx, cy, k1, k2, k3, 0, 0, 0]';
        case 'RADIAL1_DIVISION1'  
            cam.params = [f, cx, cy, k1, 0]';
        case 'RADIAL2_DIVISION2'  
            cam.params = [f, cx, cy, k1, k2, 0, 0]';
        case 'OPENCV'         
        	cam.params = [fx, fy, cx, cy, k1, k2, p1, p2]';    
        case 'OPENCV_FISHEYE'         
        	cam.params = [fx, fy, cx, cy, 0, 0, 0, 0]';    
        case 'FULL_OPENCV'         
        	cam.params = [fx, fy, cx, cy, k1, k2, p1, p2, k3, 0, 0, 0]';
        otherwise
            error('Unknown camera model!');
    end
end

