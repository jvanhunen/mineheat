function Tout = mine_plots (igeom, xo, x, d, np, nn, pipe_nodes, Tp, Tn, Q, H, Ho, Tr, Tf, q, colourBar)
% 
% This routine plots temperature T, flow Q and fluid pressure (hydraulic
% head ) H distributions across the mine network.
%
% Version 20210630 Jeroen van Hunen

%%% Retrieve inflow and outflow nodes
qin_node = find(q<0);
qout_node = find(q>0);

dplot = 2;   % Thickness of pipe segments in plot    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FIGURE 1 - Temperature field   %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1), clf

%%%%% Case 1 - if only 2D, or if 3D with no z-separation provided
% if size(x,2) == 2 | (size(x,2) == 3 & numel(unique([xo(:,3);x(:,3)]))==1)
    
    axis equal
    xlabel('x(m)')
    ylabel('y(m)')
    xtotal = [xo; x];
    dmax = max(d);
    %subplot(3,1,1)
    grid on
    hold on
    colormap(colourBar)
    caxis([max(min(min(Tp)),Tf), min(max(max(Tp)),Tr)]);
    %         caxis([min(min(Tp)) Tr]);
    for ip = 1:np
        x1 = xtotal(pipe_nodes(ip,1),1);
        x2 = xtotal(pipe_nodes(ip,2),1);
        y1 = xtotal(pipe_nodes(ip,1),2);
        y2 = xtotal(pipe_nodes(ip,2),2);
        T1 = Tp(ip,1);
        T2 = Tp(ip,2);
        z1 = 0;
        z2 = 0;
        x = [x1 x2];
        y = [y1 y2];
        z = [z1 z2];
        col = [T1 T2];
        surface([x;x],[y;y],[z;z],[col;col],...
            'facecol','no',...
            'edgecol','interp',...
            'linew',d(ip)/dmax*dplot);
        if (nn<20)
            plot(xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
        end
    end
    plot(xtotal(qin_node,1),xtotal(qin_node,2),'co','markerfacecolor','c')
    %         text(xtotal(qin_node,1),xtotal(qin_node,2),'\downarrow','color','c')
    hold on
    plot(xtotal(qout_node,1),xtotal(qout_node,2),'ro','markerfacecolor','r')
    hcb = colorbar;
    hcb.Label.String = 'Temperature';
    title(hcb,'T(^oC)')
    
% elseif size(x,2) == 3 & numel(unique([xo(:,3);x(:,3)]))~=1
%     
%         xtotal = [xo; x];
%         seamDepths = sort(unique([xo(:,3);x(:,3)]),'ascend');
%         seamTitle = {'Lower Seam','Upper Seam'};
        
%     for i = 1:2
%         subplot(1,2,i)   %%%% Lower seam
%         
%         axis equal
%         xlabel('x(m)')
%         ylabel('y(m)')
%         dmax = max(d);
%         xtotalSeam = xtotal(xtotal(:,3)==seamDepths(i),:);
%         grid on
%         hold on
%         colormap(colourBar)
%         caxis([max(min(min(Tp)),Tf), min(max(max(Tp)),Tr)]);
%         %         caxis([min(min(Tp)) Tr]);
%         for ip = 1:np
%             if xtotal(pipe_nodes(ip,1),3) == seamDepths(i) & xtotal(pipe_nodes(ip,2),3) == seamDepths(i);
%             x1 = xtotal(pipe_nodes(ip,1),1);
%             x2 = xtotal(pipe_nodes(ip,2),1);
%             y1 = xtotal(pipe_nodes(ip,1),2);
%             y2 = xtotal(pipe_nodes(ip,2),2);
%             T1 = Tp(ip,1);
%             T2 = Tp(ip,2);
%             z1 = 0;
%             z2 = 0;
%             x = [x1 x2];
%             y = [y1 y2];
%             z = [z1 z2];
%             col = [T1 T2];
%             surface([x;x],[y;y],[z;z],[col;col],...
%                 'facecol','no',...
%                 'edgecol','interp',...
%                 'linew',d(ip)/dmax*dplot);
%             if (nn<20)
%                 plot(xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
%             end
%         end
%         plot(xtotal(qin_node,1),xtotal(qin_node,2),'co','markerfacecolor','c')
%         %         text(xtotal(qin_node,1),xtotal(qin_node,2),'\downarrow','color','c')
%         hold on
%         plot(xtotal(qout_node,1),xtotal(qout_node,2),'ro','markerfacecolor','r')
%         hcb = colorbar;
%         hcb.Label.String = 'Temperature';
%         title(hcb,'T(^oC)')
%         title(seamTitle{i})
%         
%         end
%     end
    
    
% end

        
        
        %view(2)
        
% f2 = figure('visible','off'); clf
%     cla(ax2);
%     axis(ax2,'equal')
%     xlabel(ax2,'x(m)')
%     ylabel(ax2,'y(m)')
%     axis(ax2,'equal')
%     hold(ax2,'on') 
%     grid(ax2,'on')
%     colormap(ax2,jet)
%     Q = Q*3600; % Convert flowrate from m^3/s to m^3/h
%     minQ = min(Q);
%     maxQ = max(Q);
%     dQ = maxQ-minQ;
%     if (abs(dQ/maxQ)<0.01)
%         eps = abs(0.01*maxQ);
%     else
%         eps = 0;
%     end
% %     caxis(ax2,[minQ-eps maxQ+eps]);
%     caxis(ax2,[10^-1 maxQ+eps]); % better image
%     for ip = 1:np
%         disp(['Currently plotting Q pipe no. ',num2str(ip)])
%         x1 = xtotal(pipe_nodes(ip,1),1);
%         x2 = xtotal(pipe_nodes(ip,2),1);
%         y1 = xtotal(pipe_nodes(ip,1),2);
%         y2 = xtotal(pipe_nodes(ip,2),2);
%         z1 = 0;
%         z2 = 0;
%         x_plot = [x1 x2];
%         y_plot = [y1 y2];
%         z_plot = [z1 z2];
%         col = [Q(ip) Q(ip)];
%         surface(ax2,[x_plot;x_plot],[y_plot;y_plot],[z_plot;z_plot],[col;col],... 
%                 'facecol','no',... 
%                 'edgecol','interp',...
%                 'linew',d(ip)/dmax*dplot);
%         if (nn<20) 
%             plot(ax2,xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
%         end
%         %view(2)
%     end
%     hcb = colorbar(ax2);
%     set(ax2,'ColorScale','log')
%     title(hcb,'Q(m^3/h)')
%     Q = Q/3600; % Convert flowrate back from m^3/h to m^3/s
% 
%     % mark inflows and outflows on layout plot
%     for i = 1:length(q_in)
%         plot(ax2,x(q_in{i},1),x(q_in{i},2),'ko',...
%             'MarkerSize',6,...
%             'MarkerFaceColor','b');
%         plot(ax2,x(q_out{i},1),x(q_out{i},2),'ko',...
%             'MarkerSize',6,...
%             'MarkerFaceColor','r');
%     end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FIGURE 2 - Flow field   %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(2), clf
    axis equal
    hold on 
    grid on
    colormap(colourBar)
    minQ = min(Q);
    maxQ = max(Q);
    dQ = maxQ-minQ;
    if (abs(dQ/maxQ)<0.01)
        eps = abs(0.01*maxQ);
    else
        eps = 0;
    end
    %caxis([minQ-eps maxQ+eps]);
    caxis([maxQ*1e-3 maxQ+eps]);
    set(gca,'ColorScale','log')
    for ip = 1:np
        x1 = xtotal(pipe_nodes(ip,1),1);
        x2 = xtotal(pipe_nodes(ip,2),1);
        y1 = xtotal(pipe_nodes(ip,1),2);
        y2 = xtotal(pipe_nodes(ip,2),2);
        z1 = 0;
        z2 = 0;
        x = [x1 x2];
        y = [y1 y2];
        z = [z1 z2];
        col = [Q(ip) Q(ip)];
        surface([x;x],[y;y],[z;z],[col;col],... 
                'facecol','no',... 
                'edgecol','interp',...
                'linew',d(ip)/dmax*dplot);
        if (nn<20) 
            plot(xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
        end
    end
    hcb = colorbar;
    title(hcb,'Q(m^3/sec)')
    hcb.Label.String = 'Volumetric Flow Rate, Q';
    view(2)
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FIGURE 3 - Hydraulic head distribution %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
figure(3), clf
    axis equal
    grid on
    hold on 
    colormap(colourBar)
    Htotal = [Ho; H];
    caxis([min(min(Htotal)) max(max(Htotal))]);
    %caxis([0.3 0.6]);
    for ip = 1:np
        x1 = xtotal(pipe_nodes(ip,1),1);
        x2 = xtotal(pipe_nodes(ip,2),1);
        y1 = xtotal(pipe_nodes(ip,1),2);
        y2 = xtotal(pipe_nodes(ip,2),2);
        H1 = Htotal(pipe_nodes(ip,1));
        H2 = Htotal(pipe_nodes(ip,2));
        z1 = 0;
        z2 = 0;
        x = [x1 x2];
        y = [y1 y2];
        z = [z1 z2];
        col = [H1 H2];
        surface([x;x],[y;y],[z;z],[col;col],... 
                'facecol','no',... 
                'edgecol','interp',...
                'linew',d(ip)/dmax*dplot);
        if (nn<20) 
            plot(xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
        end
    end
    hcb = colorbar;
    title(hcb,'H(m)')
    view(2)
    
    
switch igeom 
    case (1 | 101 | 102)
    figure(4), clf
        x = xtotal(:,1);    % x-coordinates
        hold on
        Tnmax = max(Tn); Tnmin = min(Tn); dTn=(max(1e-30,Tnmax-Tnmin)); Tnondim = (Tn-Tnmin)/dTn;
        plot(x,Tnondim,'o');
        Hmax = max(Htotal); Hmin = min(Htotal); dH=(max(1e-30,Hmax-Hmin)); Hnondim = (Htotal-Hmin)/dH;
        plot(x,Hnondim,'x');
        title(['Hmin= ', num2str(Hmin), ', Hmax= ', num2str(Hmax), ', Tmin= ', num2str(Tnmin), ', Tmax= ', num2str(Tnmax)]);
end

drawnow

disp (['Max node temperature = ', num2str(max(abs(Tn))), ' degC']) % not correct, error in model
disp (['Max flow rate = ', num2str(1e3*max(abs(Q))), ' litres/sec']) 
