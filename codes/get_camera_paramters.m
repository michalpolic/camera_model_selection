function [ params ] = get_camera_paramters( cam, d, setting )
%GET_CAMERA_PARAMTERS - express colmap params array for given model

    % division to polynomial radial distortion
    rd = rddiv2pol(struct('type','KRCrd','K',eye(3),'R',eye(3),'C',[0 0 0]','r',d),1);
    k = rd.r;
    
    % setup focal, pp
    if isfield(setting,'cam_model') && isfield(setting,'cam_calib') && isfield(setting.cam_calib,setting.cam_model)
        gt_cam = setting.cam_calib.(setting.cam_model);
        if strcmp(setting.cam_model,'PINHOLE') || strcmp(setting.cam_model,'OPENCV') || ...
                strcmp(setting.cam_model,'OPENCV_FISHEYE') || strcmp(setting.cam_model,'FULL_OPENCV')
            f = 0.5*(gt_cam.params(1) + gt_cam.params(2));
            fx = gt_cam.params(1);
            fy = gt_cam.params(2);
            cx = gt_cam.params(3);
            cy = gt_cam.params(4);
        else
            f = gt_cam.params(1);
            fx = f;
            fy = f;
            cx = gt_cam.params(2);
            cy = gt_cam.params(3);
        end
    else 
        f = cam.f;
        fx = f;
        fy = f;
        cx = cam.pp(1);
        cy = cam.pp(2);
    end
    
    % setup the parameters 
    switch setting.cam_model
        case 'SIMPLE_PINHOLE'
            params = [f, cx, cy]';
        case 'PINHOLE'
            params = [fx, fy, cx, cy]';
        case 'SIMPLE_RADIAL'
            params = [f, cx, cy, k(1)]';
        case 'RADIAL'
            params = [f, cx, cy, k(1), k(2)]';
        case 'DIVISION1'     
            params = [f, cx, cy, d(1)]';
        case 'DIVISION2'      
            params = [f, cx, cy, d(1), 0]';
        case 'DIVISION3'     
            params = [f, cx, cy, d(1), 0, 0]';
        case 'DIVISION4'      
            params = [f, cx, cy, d(1), 0, 0, 0]';
        case 'I_DIVISION1'
            params = [f, cx, cy, 0.01]';
        case 'I_DIVISION2'
            params = [f, cx, cy, 0.01, 0.001]';   
        case 'SIMPLE_RADIAL_FISHEYE'
            params = [f, cx, cy, 0]';
        case 'RADIAL_FISHEYE'
            params = [f, cx, cy, 0, 0]';
        case 'RADIAL3'
            params = [f, cx, cy, k(1), k(2), k(3)]';
        case 'RADIAL4'  
            params = [f, cx, cy, k(1), k(2), k(3), 0]';
        case 'RADIAL3_DIVISION1'  
            params = [f, cx, cy, k(1), k(2), k(3), 0]';
        case 'RADIAL3_DIVISION2'  
            params = [f, cx, cy, k(1), k(2), k(3), 0, 0]';
        case 'RADIAL3_DIVISION3'  
            params = [f, cx, cy, k(1), k(2), k(3), 0, 0, 0]';
        case 'RADIAL1_DIVISION1'  
            params = [f, cx, cy, 0, d(1)]';
        case 'RADIAL2_DIVISION2'  
            params = [f, cx, cy, 0, 0, d(1), 0]';
        case 'OPENCV'         
        	params = [fx, fy, cx, cy, k(1), k(2), p1, p2]';    
        case 'OPENCV_FISHEYE'         
        	params = [fx, fy, cx, cy, 0, 0, 0, 0]';    
        case 'FULL_OPENCV'         
        	params = [fx, fy, cx, cy, 0, 0, p1, p2, 0, d(1), 0, 0]';
        otherwise
            error('Unknown camera model!');
    end

end

