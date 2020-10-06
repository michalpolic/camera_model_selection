function [ colors ] = getColors( n )
    
    % basic colors
    colors = {  [0,0.4275,1];...
                [0,1,0.7843];...
                [0.0510,0.6941,0.1765];...
                [0.9490,0.9490,0];...
                [0.9490,0.6588,0];...
                [1,0,0];...
                [0.9490,0,0.7059];...
                [0.5882,0,0.9490] };
    
    % more colors
    if(size(colors,1) < n)
        for i = 1 : size(colors,1)
            colors{end+1} = colors{i}*0.5;
        end
    end

    % stil more colors
    if(size(colors,1) < n)
        while( size(colors,1) < n)
            colors{end+1} = rand(1,3);
        end
    end
end

