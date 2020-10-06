function mboxplot(data, fnoises, lims, x_label, y_label, methodsNames, cols, nolegend)


% random data
%data = [];
%for j=1:3
%data{j} = rand(6,100)-0.7;
%end


   % data{1} = mhzerr;
   % data{2} = mhhzerr;
   % data{3} = zerr;
   % data{4} = hzerr;
    
  %  data{1} = rx_hz;
  %  data{2} = rx_tsai;
  %  data{3} = rx_minhec;
  %  data{4} = rx_hminhec;
   
    
% noise levels
pixel = 1;
%fnoises = [0:0.1:1]; %;[0 0.01 0.1 0.5 1 2]*pixel;
%lims =  [0    0.1];

cfgs = [1];
%methodsNames = {'1.Method' '2.Method' '3.Method' '4.Method' '5.Method'};
%methods = [1 2 3];
%methodsb = [1 1 1 0 0 ];


methods = 1:(numel(data));
%methods = [1 2 3 4];

%methodsb = [1 1 1 1 0 ];

name = '';

%ground truth
lambdas = [ -0.2];


%cols = {'r' 'b' 'm' 'green' 'c' 'm' 'y' 'r' 'g' 'b' 'k' 'c' 'm' 'y' 'r' 'g' 'b' 'k' 'c' 'm' 'y'};       % colors
%cols = {'r' 'b' 'm' 'green' 'c'};
%cols = { [1 0 0] [0 0 1] [1 1 0] [0 1 0] [0 1 1]};

bBoxPlotNoise1 =1;

collector = [];
ncnt = length(fnoises);

    
    i = 1;
    ii = 1;


    hnd = figure;
    axes_handle=axes('fontsize', 16);
    hold on;
    set(hnd, 'Name', name);
    title(name);

    
    
    ylim(axes_handle, lims);
    xlim(axes_handle, [0.4 length(fnoises)+0.5]);

    xt = [];
    xn = {};

    for ns=1:length(methods)
        plot(-1,-1, 'Color', cols{ns});
    end
    
    for ns=1:length(fnoises)
        xt(ns) = ns*1;
        xn{ns} = num2str(fnoises(ns)/pixel);
    end

    set(gca,'XTick', xt);
    set(gca,'XTickLabel', xn);

    xlabel(x_label, 'fontsize', 16);
    ylabel(y_label, 'fontsize', 16);

    for ns=2:length(fnoises)
        plot([ns-0.5 ns-0.5], [lims(1) lims(2)], ['-'], 'LineWidth', 1, 'color', [0.9 0.9 0.9]);
    end

    metshift = 0.9/length(methods);
    xsize = metshift/2-0.02;
    xxsize = metshift/4-0.02;
    ofs = (1 + xsize) - (metshift * length(methods)) / 2;

    cfg = cfgs(1);

    % ground truth
    %plot([0 10], [lambdas(1) lambdas(1)], 'Color', 'cyan');

    scollector = [];
    for j=methods

        xstart = ofs;
        xpos = xstart;

        for ns=1:length(fnoises)

            x = [];
            
            % plenie nat
            mx = data{j}(ns, :);
            x = [x; mx(:)];
     

            [outlier,loadj,upadj,yy,q1,q3,n2,med,n1] = mb_boxutil(x, 1,1.5,0);

            plot([xpos xpos], [q1 n2], ['--'], 'Color', cols{ii}, 'LineWidth', 1);
            plot([xpos xpos], [q3 n1], ['--'], 'Color', cols{ii}, 'LineWidth', 1);

            %plot(xpos * ones(1, length(yy)), yy, ['+' cols{ii}], 'MarkerSize', 3);

            plot([xpos-xxsize xpos+xxsize], [q1 q1], ['-'], 'Color', cols{ii}, 'LineWidth', 1);
            plot([xpos-xxsize xpos+xxsize], [q3 q3], ['-'], 'Color', cols{ii}, 'LineWidth', 1);

            plot([xpos-xsize xpos+xsize xpos+xsize xpos-xsize xpos-xsize], [n1 n1 n2 n2 n1], ['-'], 'Color', cols{ii}, 'LineWidth', 1);

            plot([xpos-xsize xpos+xsize], [med med], ['-'], 'Color', cols{ii}, 'LineWidth', 2);

            stat = [n2, med, n1];
      
            i=i+1;
            xpos = xpos + 1;
        end

      
        ofs = ofs + metshift;
        ii = ii + 1;

        if (~((nargin > 7) && (nolegend == 1)))
            legend(methodsNames(methods));
        end

    end
