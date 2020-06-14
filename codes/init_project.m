function [ reconstr_database, sparse_reconstr ] = init_project( project_dir, database_path, rdF10e, setting )
%INIT_PROJECT - init colmap computotion project
    
    % create directories / copy files
    sparse_reconstr = fullfile(project_dir,'sparse');
    mkdir(project_dir);
    mkdir(sparse_reconstr);
    copyfile(database_path, fullfile(project_dir),'f');
    reconstr_database = fullfile(project_dir,'database.db');
    
    % establish connection to the database
    javaaddpath('/home/policmic/documents/libs/sqlite-jdbc-3.8.7.jar');
    conn = database(reconstr_database,[],[],'org.sqlite.JDBC',sprintf('jdbc:sqlite:%s',reconstr_database)); 
    cameras = fetch(conn,'SELECT camera_id,params,width,height FROM cameras');
    
    % load existing camera model
    cam = struct();
    cam.id = cameras{1,1};
    params = typecast(cell2mat(cameras{1,2}),'double');
    cam.f = params(1);
    cam.pp = params(2:3);
    cam.width = cameras{1,3};
    cam.height = cameras{1,4};
    
    % modify camera model / parameters in database
    params = get_camera_paramters(cam, rdF10e, setting);
    update(conn,'cameras',{'model','params'}, {model2model_id(setting.cam_model),typecast(params(:), 'int8')}, ...
           sprintf('WHERE camera_id = %d',cam.id)); 
    
    % close 
    close(conn);
end

