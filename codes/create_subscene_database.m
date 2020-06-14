function [ new_database_path ] = create_subscene_database( database_path, selected_images )
%create_subscene_database - copy database, remove all imgs which are not in selected_images
    
    % copy database
    [a, b, c] = fileparts(database_path);
    new_database_path = fullfile(a,sprintf('%s_%02d%s',b,length(selected_images),c));
    copyfile(database_path, new_database_path);
    
    % remove images, matches, keypoints which are not selected
    conn = database(new_database_path,[],[],'org.sqlite.JDBC',sprintf('jdbc:sqlite:%s',new_database_path)); 
    image_ids = cell2mat(fetch(conn,'SELECT image_id FROM images'));
    [~,IA,~] = intersect(image_ids,selected_images);
    image_ids(IA) = [];
    
    % remove all data for one image
    for i = 1:size(image_ids,1)
        tic; fprintf('Remove the image %d from database ... ',image_ids(i))
        exec(conn,sprintf('DELETE FROM images WHERE image_id = %d',image_ids(i)));
        exec(conn,sprintf('DELETE FROM descriptors WHERE image_id = %d',image_ids(i)));
        exec(conn,sprintf('DELETE FROM keypoints WHERE image_id = %d',image_ids(i)));
        
        % matches
        data = fetch(conn,'SELECT pair_id FROM matches');
        for j = 1:length(data)
            image_id2 = mod(data{j},2147483647);
            image_id1 = (data{j} - image_id2) / 2147483647;
            if sum(image_ids == image_id1) > 0 || sum(image_ids == image_id2) > 0
                exec(conn,sprintf('DELETE FROM matches WHERE pair_id = %d',data{j}));
                exec(conn,sprintf('DELETE FROM two_view_geometries WHERE pair_id = %d',data{j}));
            end
        end
        fprintf(' %.2%sec\n',toc)
    end
    close(conn); 
    
end

