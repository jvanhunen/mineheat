%% This program allows for the computation of water and heat flow through a mine network
%%     Copyright (C) 2022  Durham University
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <https://www.gnu.org/licenses/>.
%%
function Tout = mine_plots_gui (ax,ax2,igeom,xo,x,d,np,nn,pipe_nodes,Tp,Tn,Q,H,Ho,q_in,q_out,Tr)
% 
% This routine plots temperature T, flow Q and fluid pressure (hydraulic
% head ) H distributions across the mine network.
%
% Version 20210630 Jeroen van Hunen

dplot = 2;   % Thickness of pipe segments in plot    
f1 = figure('visible','off'); clf
    cla(ax);
    axis(ax,'equal')
    xlabel(ax,'x(m)')
    ylabel(ax,'y(m)')
    xtotal = [xo; x];
    dmax = max(d);
    %subplot(3,1,1)
        grid(ax,'on')
        hold(ax,'on') 
        colormap(ax,jet)
%         caxis(ax,[min(min(Tp)) max(max(Tp))]);
        caxis(ax,[min(min(Tp)) Tr]);
        for ip = 1:np
            disp(['Currently plotting T pipe no. ',num2str(ip)])
            x1 = xtotal(pipe_nodes(ip,1),1);
            x2 = xtotal(pipe_nodes(ip,2),1);
            y1 = xtotal(pipe_nodes(ip,1),2);
            y2 = xtotal(pipe_nodes(ip,2),2);
            T1 = Tp(ip,1);
            T2 = Tp(ip,2);
            z1 = 0;
            z2 = 0;
            x_plot = [x1 x2];
            y_plot = [y1 y2];
            z_plot = [z1 z2];
            col = [T1 T2];
            surface(ax,[x_plot;x_plot],[y_plot;y_plot],[z_plot;z_plot],[col;col],... 
                    'facecol','no',... 
                    'edgecol','interp',...
                    'linew',d(ip)/dmax*dplot);
            if (nn<20) 
                plot(ax,xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
            end
            %view(2)
        end
        hcb = colorbar(ax);
        title(hcb,'T(^oC)') 
        
        % mark inflows and outflows on layout plot
    for i = 1:length(q_in)
        plot(ax,x(q_in{i},1),x(q_in{i},2),'ko',...
            'MarkerSize',6,...
            'MarkerFaceColor','b');
        plot(ax,x(q_out{i},1),x(q_out{i},2),'ko',...
            'MarkerSize',6,...
            'MarkerFaceColor','r');
    end
        
f2 = figure('visible','off'); clf
    cla(ax2);
    axis(ax2,'equal')
    xlabel(ax2,'x(m)')
    ylabel(ax2,'y(m)')
    axis(ax2,'equal')
    hold(ax2,'on') 
    grid(ax2,'on')
    colormap(ax2,jet)
    Q = Q*3600; % Convert flowrate from m^3/s to m^3/h
    minQ = min(Q);
    maxQ = max(Q);
    dQ = maxQ-minQ;
    if (abs(dQ/maxQ)<0.01)
        eps = abs(0.01*maxQ);
    else
        eps = 0;
    end
%     caxis(ax2,[minQ-eps maxQ+eps]);
    caxis(ax2,[10^-1 maxQ+eps]); % better image
    for ip = 1:np
        disp(['Currently plotting Q pipe no. ',num2str(ip)])
        x1 = xtotal(pipe_nodes(ip,1),1);
        x2 = xtotal(pipe_nodes(ip,2),1);
        y1 = xtotal(pipe_nodes(ip,1),2);
        y2 = xtotal(pipe_nodes(ip,2),2);
        z1 = 0;
        z2 = 0;
        x_plot = [x1 x2];
        y_plot = [y1 y2];
        z_plot = [z1 z2];
        col = [Q(ip) Q(ip)];
        surface(ax2,[x_plot;x_plot],[y_plot;y_plot],[z_plot;z_plot],[col;col],... 
                'facecol','no',... 
                'edgecol','interp',...
                'linew',d(ip)/dmax*dplot);
        if (nn<20) 
            plot(ax2,xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
        end
        %view(2)
    end
    hcb = colorbar(ax2);
    set(ax2,'ColorScale','log')
    title(hcb,'Q(m^3/h)')
    Q = Q/3600; % Convert flowrate back from m^3/h to m^3/s

    % mark inflows and outflows on layout plot
    for i = 1:length(q_in)
        plot(ax2,x(q_in{i},1),x(q_in{i},2),'ko',...
            'MarkerSize',6,...
            'MarkerFaceColor','b');
        plot(ax2,x(q_out{i},1),x(q_out{i},2),'ko',...
            'MarkerSize',6,...
            'MarkerFaceColor','r');
    end
    
% f3 = figure('visible','off'); clf
%     axis equal
%     grid on
%     hold on 
%     colormap(jet)
%     Htotal = [Ho; H];
%     caxis([min(min(Htotal)) max(max(Htotal))]);
%     caxis([0.3 0.6]);
%     for ip = 1:np
%         x1 = xtotal(pipe_nodes(ip,1),1);
%         x2 = xtotal(pipe_nodes(ip,2),1);
%         y1 = xtotal(pipe_nodes(ip,1),2);
%         y2 = xtotal(pipe_nodes(ip,2),2);
%         H1 = Htotal(pipe_nodes(ip,1));
%         H2 = Htotal(pipe_nodes(ip,2));
%         z1 = 0;
%         z2 = 0;
%         x = [x1 x2];
%         y = [y1 y2];
%         z = [z1 z2];
%         col = [H1 H2];
%         surface([x;x],[y;y],[z;z],[col;col],... 
%                 'facecol','no',... 
%                 'edgecol','interp',...
%                 'linew',d(ip)/dmax*dplot);
%         if (nn<20) 
%             plot(xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
%         end
%         hcb = colorbar;
%         title(hcb,'H(m)')
%         view(2)
%     end
% 
% if igeom ==1 || igeom==101 || igeom==102
%     f4 = figure('visible','off'); clf
%         x = xtotal(:,1);    % x-coordinates
%         hold on
%         Tnmax = max(Tn); Tnmin = min(Tn); dTn=(max(1e-30,Tnmax-Tnmin)); Tnondim = (Tn-Tnmin)/dTn;
%         plot(x,Tnondim,'o');
%         Hmax = max(Htotal); Hmin = min(Htotal); dH=(max(1e-30,Hmax-Hmin)); Hnondim = (Htotal-Hmin)/dH;
%         plot(x,Hnondim,'x');
%         title(['Hmin= ', num2str(Hmin), ', Hmax= ', num2str(Hmax), ', Tmin= ', num2str(Tnmin), ', Tmax= ', num2str(Tnmax)]);
% end

drawnow
