function rd_d = update_matches_by_F10e( database_path, imgs_dir, setting, results_dir )
%UPDATE_MATCHES_BY_F10E - load matches, verify them by F10e and save them
%into database

    % test database
    if ~exist(database_path,'file')
        error('The database does not exist.');
    end
    tic; fprintf('> load keypoints and matches from database ... ')   
    write_status(fullfile(results_dir,'status.txt'), sprintf('> update verified matches by F10e ... '))

    % establish connection to the database
    conn = database(database_path,[],[],'org.sqlite.JDBC',sprintf('jdbc:sqlite:%s',database_path)); 
    
    % load the number of images
    images = fetch(conn,'SELECT image_id,name FROM images');
    img_ids = table2array(images(:,1));
    img_names = images{:,2};
    img_info = cell(size(img_names,1),1);
    warning('off');
    for i = 1:size(img_names,1)
        img_info{i} = imfinfo(fullfile(imgs_dir,img_names{i}));
    end
    warning('on');
    
    % load info about cameras
    cameras = fetch(conn,'SELECT camera_id,params,width,height FROM cameras');
    cam = struct();
    cam.id = cameras{1,1};
    params = typecast(cell2mat(cameras{1,2}),'double');
    cam.f = params(1);
    cam.pp = params(2:3);
    cam.width = cameras{1,3};
    cam.height = cameras{1,4};
    
    % load all keypoints
    N = size(img_ids,1);
    keypoints = cell(N,1);
    for i = 1:N
        ks = struct();      % keypoint structure
        data = fetch(conn,sprintf('SELECT rows,cols,data FROM keypoints WHERE image_id = %d',img_ids(i)));
        d = reshape(typecast(cell2mat(data{1,3}),'single'),data{1,2},data{1,1});
        ks.img_id = img_ids(i);
        ks.img_name = img_names{i};
        ks.obs = d([1,2],:);
        ks.A = d(3:end,:);
        keypoints{i} = ks;
    end
       
    % load all tentative matches
    k = 1;
    matches = cell(nchoosek(N, 2), 1);
    match_ids = zeros(nchoosek(N, 2),2);
    pair_matches = cell(nchoosek(N, 2),1);
    for i = 1:N
        for j = i+1:N
            match_ids(k,:) = [i,j];
            img_pair_id = to_pair_id(img_ids(i), img_ids(j));
            data = fetch(conn,sprintf('SELECT rows,cols,data FROM matches WHERE pair_id=%d',img_pair_id));
            if ~isempty(data)
                pair_matches{k} = reshape(typecast( cell2mat(data{1,3}) , 'uint32'),data{1,2},data{1,1}) + 1;  % indexes from 1
            end
%             % switch according ids
%             if img_ids(i) > img_ids(j)  
%                 pair_matches{k} = pair_matches{k}([2,1],:);
%             end
            k = k + 1;
        end
    end
    
    % parallel matching by F10e
    rd_d_coeff = zeros(nchoosek(N, 2),2);
    f = cam.f;
    pp = cam.pp;
    max_keypoints =  max( cellfun(@(k) size(k.obs,2), keypoints) );
    inliers_img1 = -ones(max_keypoints,nchoosek(N, 2));
    inliers_img2 = -ones(max_keypoints,nchoosek(N, 2));
    image_pairs_E = zeros(9,nchoosek(N, 2));
    image_pairs_F = zeros(9,nchoosek(N, 2));
    parfor k = 1:size(match_ids,1)         % 
        fprintf('> process pair %d/%d ... \n',k,size(matches,1))   
        img1_id = img_ids(match_ids(k,1));
        img2_id = img_ids(match_ids(k,2));
        if img1_id > img2_id
            tmp = img1_id;
            img1_id = img2_id;
            img2_id = tmp;
        end
        k1 = keypoints{cellfun(@(k) k.img_id, keypoints) == img1_id};
        k2 = keypoints{cellfun(@(k) k.img_id, keypoints) == img2_id};

        % verify tentative matches 
        inliers = [];
        if size(pair_matches{k},2) > 15
            K = [f 0 pp(1); 0 f pp(2); 0 0 1];
            [inliers, model, ~] = verify_matches( k1.obs, k2.obs, pair_matches{k}, K, K, setting );
            E = model.F;       
            F = (K') \ model.F / K;
            
            % fill global arrays
            n = size(inliers,2);
            inliers_long_img1 = -ones(max_keypoints,1);
            inliers_long_img1(1:n) = inliers(1,:);
            inliers_img1(:,k) = inliers_long_img1;
            
            inliers_long_img2 = -ones(max_keypoints,1);
            inliers_long_img2(1:n) = inliers(2,:);
            inliers_img2(:,k) = inliers_long_img2;
            image_pairs_E(:,k) = E(:);
            image_pairs_F(:,k) = F(:);
            rd_d_coeff(k,:) = [model.l1, model.l2];
        end

%             % plot the matched keypoints
%             I1 = rgb2gray(imread(fullfile(project_dir,'images',k1.img_name)));
%             I2 = rgb2gray(imread(fullfile(project_dir,'images',k2.img_name)));
%             figure; ax = axes;
%             showMatchedFeatures(I1, I2, double(k1.obs(:,inliers(1,:)))', double(k2.obs(:,inliers(2,:)))', 'montage', 'Parent', ax);

        % update verified matches
        % data = fetch(conn,sprintf('SELECT rows,cols,data,F FROM two_view_geometries WHERE pair_id=%d',img_pair_id));
%         update(parfor_conn,'two_view_geometries',{'rows','cols','data','config','E','F'},...
%             {length(inliers), 2, typecast(inliers(:)-1, 'int8'), 2, typecast(E(:), 'int8'), ...
%             typecast(F(:), 'int8')}, sprintf('WHERE pair_id = %d',img_pair_id)); 
        
%         close(parfor_conn);
    end
    
    % load F10e updated matches
    for k = 1:size(match_ids,1)
        img_pair_id = to_pair_id(img_ids(match_ids(k,1)), img_ids(match_ids(k,2))); 
        inliers = uint32([inliers_img1(inliers_img1(:,k) ~= -1,k)'; inliers_img2(inliers_img2(:,k) ~= -1,k)']);
        
        % update verified matches
        update(conn,'two_view_geometries',{'rows','cols','data','config','E','F'},...
            {length(inliers), 2, typecast(inliers(:)-1, 'int8'), 2, typecast(image_pairs_E(:,k), 'int8'), ...
            typecast(image_pairs_F(:,k), 'int8')}, sprintf('WHERE pair_id = %d',img_pair_id)); 
    end
        
    % update camera parameters
%     rd_d_coeff = [cellfun(@(m) m.l1, matches); cellfun(@(m) m.l2, matches)];
    rd_d = median(rd_d_coeff(:));
    params = get_camera_paramters(cam, rd_d, setting);
    update(conn,'cameras',{'params'}, {typecast(params(:), 'int8')}, ...
        sprintf('WHERE camera_id = %d',cam.id)); 

    % close 
    close(conn);
    
    % save results
%     save(fullfile(project_dir,'matches.mat'),'keypoints','matches','-v7.3');
    runtime = toc;
    fprintf('%.2fsec\n',runtime)
    write_status(fullfile(results_dir,'status.txt'), sprintf('%.2fsec</br>\n',runtime))
end

function pair_id = to_pair_id(image_id1, image_id2)
    if image_id1 > image_id2
        pair_id = 2147483647 * image_id2 + image_id1;
    else
        pair_id = 2147483647 * image_id1 + image_id2;
    end
end
