function write_quantitative_results(res_file, cam_model, one_res)
    fid = fopen( res_file, 'at' );
    fprintf( fid, 'Camera model: %s</br>\n', cam_model);
    fprintf( fid, '> SfM runtime: %.2fsec</br>\n', one_res.sfm_time);
    fprintf( fid, '> registered images: %d</br>\n', one_res.nimgs);
    fprintf( fid, '> trinagulated points: %d</br>\n', one_res.npts);
    fprintf( fid, '> registered / detected observations: %d / %d</br>\n', one_res.nobs, one_res.nobs_all);
    fprintf( fid, '> mean reproj. error: %.2fpx</br></br>\n\n', mean(cell2mat(one_res.residuals')));
    fclose(fid);
end
