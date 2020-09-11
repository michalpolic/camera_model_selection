function saveColmap( directory, cameras, images, points3D )
%SAVECOLMAP - save the colmap structures into the files

    if (isempty(directory)) 
        error('saveColmap: wrong output directory!');
    end 
    if (directory(end) == '/')
        directory = directory(1:end-1);
    end

    write_cameras([directory filesep 'cameras.txt'], cameras);
    write_images([directory filesep 'images.txt'], images);
    write_points3D([directory filesep 'points3D.txt'], points3D);
end

% Tomas Pajdla, pajdla@cmp.felk.cvut.cz
% 2001-03-12
function q = r2q(R)
    R = R(1:3,1:3);
    c = trace(R)+1;
    if abs(c)<10000*eps % 180 degrees
        S = R+eye(3);
        [~,mi]=max(vnorm(S));
        q = [0;S(:,mi)/vnorm(S(:,mi))];
    else
        q = [sqrt(c)/2;
             (R(3,2)-R(2,3))/sqrt(c)/2;
             (R(1,3)-R(3,1))/sqrt(c)/2;
             (R(2,1)-R(1,2))/sqrt(c)/2];
        %q = q/vnorm(q); 
    end
end

function write_cameras(path, cams)
    fid = fopen(path, 'w');
    fprintf(fid, '# Camera list with one line of data per camera:\n');
    fprintf(fid, '#   CAMERA_ID, MODEL, WIDTH, HEIGHT, PARAMS[]\n');
    
    cams_vals = cams.values;
    fprintf(fid, '# Number of cameras: %d\n', cams.Count);
    
    for i = 1:cams.Count
        cam = cams_vals{i};
        fprintf(fid, '%d %s %d %d', cam.camera_id, cam.model, cam.width, cam.height);
        fprintf(fid, ' %f',cam.params);
        fprintf(fid, '\n');
    end
    fclose(fid);
end

function write_images(path, imgs)
    fid = fopen(path, 'w');
    fprintf(fid, '# Image list with two lines of data per image:\n');
    fprintf(fid, '#   IMAGE_ID, QW, QX, QY, QZ, TX, TY, TZ, CAMERA_ID, NAME\n');
    fprintf(fid, '#   POINTS2D[] as (X, Y, POINT3D_ID)\n');
    
    imgs_vals = imgs.values;
    fprintf(fid, '# Number of images: %d, mean observations per image: not-defined\n', imgs.Count);
    
    for i = 1:imgs.Count
        img = imgs_vals{i};
        fprintf(fid, '%d ', img.image_id);
        if isfield(img,'q')
            fprintf(fid, '%f ', img.q);
        else
            fprintf(fid, '%f ', r2q(img.R));
        end
        fprintf(fid, '%f ', img.t);
        fprintf(fid, '%d %s\n', img.camera_id, strtrim(img.name));
        
        for j = 1:size(img.xys,1)
            fprintf(fid, '%f %f %d ',img.xys(j,1), img.xys(j,2), img.point3D_ids(j));
        end
        
        %iop = [img.xys'; img.point3D_ids'];
        fprintf(fid, '\n');
    end
    fclose(fid);
end

function write_points3D( path, points3D )
    fid = fopen(path, 'w');
    fprintf(fid, '# 3D point list with one line of data per point:\n');
    fprintf(fid, '#   POINT3D_ID, X, Y, Z, R, G, B, ERROR, TRACK[] as (IMAGE_ID, POINT2D_IDX)\n');
    
    pts_vals = points3D.values;
    fprintf(fid, '# Number of points: %d, mean track length: not-defined\n',points3D.Count);
   
    for i = 1:points3D.Count
        pt = pts_vals{i};
        fprintf(fid, '%d ', pt.point3D_id);
        fprintf(fid, '%f ', pt.xyz);
        fprintf(fid, '%d ', pt.rgb);
        fprintf(fid, '%f ', pt.error);
        fprintf(fid, '%f ', pt.track);
        fprintf(fid, '\n');
    end
    fclose(fid);
end
