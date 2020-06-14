function write_status(status_file, status_message, par)
    if nargin < 3
       par = 'at'; 
    end
    fid = fopen( status_file, par );
    fprintf( fid, '%s', status_message);
    fclose(fid);
end

