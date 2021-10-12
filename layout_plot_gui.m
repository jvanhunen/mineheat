function layout_plot_gui (ax, nn, xo, x, d, np, pipe_nodes,q_in,q_out)
%
% used in GUI to plot the model layout and number the nodes
% this is used for visual interaction with the user and inflow and outflow
% node selection in the GUI
%
% Future add-ons: pipe numbers

% This is a bit useless, but there for now
% Change if grid size changes
n = 10;
m = 15;

% plots the pipe of the mine grid
dplot = 2;
f1 = figure('visible','off'); clf
    cla(ax);
    axis(ax,'equal')
    xlabel(ax,'x(m)')
    ylabel(ax,'y(m)')
    xtotal = [xo; x];
    dmax = max(d);
        grid(ax,'on')
        hold(ax,'on') 
        for ip = 1:np
            x1 = xtotal(pipe_nodes(ip,1),1);
            x2 = xtotal(pipe_nodes(ip,2),1);
            y1 = xtotal(pipe_nodes(ip,1),2);
            y2 = xtotal(pipe_nodes(ip,2),2);
            z1 = 0;
            z2 = 0;
            x_plot = [x1 x2]; % x changed to x_plot
            y_plot = [y1 y2]; % y changed to y_plot
            z_plot = [z1 z2]; % z changed to z-plot
            col = [1 1];
            surface(ax,[x_plot;x_plot],[y_plot;y_plot],...
                    [z_plot;z_plot],[col;col],... 
                    'facecol','no',... 
                    'edgecol','interp',...
                    'linew',d(ip)/dmax*dplot);
%             % plots the pipe numbers, comment out when plotting node
%             % numbers
%             if ip<=(n-1)*m
%                 text(ax,x1,y1,num2str(ip),...
%                 'FontSize',10,...
%                 'Color', 'k');
%             else
%                 text(ax,x2,(y1+abs(y1-y2)/2),num2str(ip),...
%                 'FontSize',10,...
%                 'Color', 'b');
%             end
        end
       
    % mark inflows and outflows on layout plot
    for i = 1:length(q_in)
        plot(ax,x(q_in{i},1),x(q_in{i},2),'ko',...
            'MarkerSize',6,...
            'MarkerFaceColor','b');
        plot(ax,x(q_out{i},1),x(q_out{i},2),'ko',...
            'MarkerSize',6,...
            'MarkerFaceColor','r');
    end
    
    % plots numbers on unknown-head nodes (all but 1 known-head node)
    % comment out when plotting pipe numbers
    if nn < 500 % number every node
        for in = 1:nn
            text(ax,x(in,1),x(in,2),num2str(in),...
                'FontSize',10,...
                'Color', 'k');
        end
    elseif nn >= 500 && nn < 1000 % number all uneven nodes
        for in = 1:2:nn
            text(ax,x(in,1),x(in,2),num2str(in),...
                'FontSize',10,...
                'Color', 'k');
        end
    else
        for in = 1:3:nn % number every third node
            text(ax,x(in,1),x(in,2),num2str(in),...
                'FontSize',10,...
                'Color', 'k');
        end
    end
end