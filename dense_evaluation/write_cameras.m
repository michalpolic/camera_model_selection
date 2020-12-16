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
