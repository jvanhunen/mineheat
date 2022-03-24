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

function Tout = mine_plots (igeom, xo, x, d, np, nn, pipe_nodes, Tp, Tn, Q, H, Ho, Tr, Tf, q, colourBar, rp, Re)
% 
% This routine plots temperature T, flow Q and fluid pressure (hydraulic
% head ) H distributions across the mine network.
% version 20220217 JMC added thermal drawdown radii plot (glitched) and
% replaced pipe temperatures with nodal temperatures
% Version 20210630 Jeroen van Hunen

%%% Retrieve inflow and outflow nodes
qin_node = find(q<0);         % 
qout_node = find(q>0);

dplot = 2;   % Thickness of pipe segments in plot    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FIGURE 1 - Temperature field   %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


xtotal = [x; xo];
dmax = max(d);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Case 1 - if only 2D, or if 3D with no z-separation provided
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if size(x,2) == 2 | (size(x,2) == 3 & numel(unique([xo(:,3);x(:,3)]))==1)
    figure(1), clf
    axis equal
    xlabel('x(m)')
    ylabel('y(m)')
    
    %     subplot(3,1,1)
    grid on
    hold on
    colormap(colourBar)
%     caxis([max(min(min(Tp)),Tf), min(max(max(Tp)),Tr)]);
    caxis([Tf Tr]);
    for ip = 1:np
        x1 = xtotal(pipe_nodes(ip,1),1);
        x2 = xtotal(pipe_nodes(ip,2),1);
        y1 = xtotal(pipe_nodes(ip,1),2);
        y2 = xtotal(pipe_nodes(ip,2),2);
        T1 = Tn(pipe_nodes(ip,1));
        T2 = Tn(pipe_nodes(ip,2));
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
%     text(xtotal(qin_node,1),xtotal(qin_node,2),'\downarrow','color','c')
    hold on
    plot(xtotal(qout_node,1),xtotal(qout_node,2),'ro','markerfacecolor','r')
    hcb = colorbar;
    hcb.Label.String = 'Temperature';
    title(hcb,'T(^oC)')
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Case 2 -  3D with z-separation provided
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif size(x,2) == 3 & numel(unique([xo(:,3);x(:,3)]))~=1
    seamDepths = sort(unique(xtotal(:,3)),'ascend');
    Z1 = xtotal(pipe_nodes(:,1),3);
    Z2 = xtotal(pipe_nodes(:,2),3);
    lowerSeam = find(Z1 == Z2 & Z1 == seamDepths(1));
    upperSeam = find(Z1 == Z2 & Z1 == seamDepths(2)); 
    linkPipe = find(Z1 ~= Z2);
    
    figure(1), clf
    axis equal
    xlabel('x(m)')
    ylabel('y(m)')
    grid on
    hold on
    title('Lower Seam')
    colormap(colourBar)
    caxis([Tf Tr]);
    for ip = 1:np
        if ismember(ip,[lowerSeam; linkPipe]) == 1              
            x1 = xtotal(pipe_nodes(ip,1),1);
            x2 = xtotal(pipe_nodes(ip,2),1);
            y1 = xtotal(pipe_nodes(ip,1),2);
            y2 = xtotal(pipe_nodes(ip,2),2);
            T1 = Tn(pipe_nodes(ip,1));
            T2 = Tn(pipe_nodes(ip,2));
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
            
            if ip == linkPipe
               plot(xtotal(pipe_nodes(ip,1),1), xtotal(pipe_nodes(ip,1),2),'kx','markerfacecolor','k')
               hold on
               plot(xtotal(pipe_nodes(ip,2),1), xtotal(pipe_nodes(ip,2),2),'kx','markerfacecolor','k')
            end
            
            if (nn<20)
                plot(xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
            end
            
            %%%% Plot inflow and outflow locations
            if ismember(pipe_nodes(ip,1),qin_node) == 1
                plot(xtotal(pipe_nodes(ip,1),1),xtotal(pipe_nodes(ip,1),2),'co','markerfacecolor','c')
            elseif ismember(pipe_nodes(ip,2),qin_node) == 1
                plot(xtotal(pipe_nodes(ip,2),1),xtotal(pipe_nodes(ip,2),2),'co','markerfacecolor','c')
            elseif ismember(pipe_nodes(ip,1),qout_node) == 1
                plot(xtotal(pipe_nodes(ip,1),1),xtotal(pipe_nodes(ip,1),2),'ro','markerfacecolor','r')
            elseif ismember(pipe_nodes(ip,2),qout_node) == 1
                plot(xtotal(pipe_nodes(ip,2),1),xtotal(pipe_nodes(ip,2),2),'ro','markerfacecolor','r')
                
            %%%% Plot link pipe locations
            elseif ismember(pipe_nodes(ip,1),linkPipe) == 1
                plot(xtotal(pipe_nodes(ip,1),1),xtotal(pipe_nodes(ip,1),2),'kx','markerfacecolor','k')
            elseif ismember(pipe_nodes(ip,2),linkPipe) == 1
                plot(xtotal(pipe_nodes(ip,2),1),xtotal(pipe_nodes(ip,2),2),'kx','markerfacecolor','k')
            end
        end
    end 
    
    hcb = colorbar;
    hcb.Label.String = 'Temperature';
    title(hcb,'T(^oC)')


    figure(4), clf
    axis equal
    xlabel('x(m)')
    ylabel('y(m)')
    grid on
    hold on
    title('Upper Seam')
    colormap(colourBar)
    caxis([Tf Tr]);
    for ip = 1:np
        if ismember(ip,[upperSeam; linkPipe]) == 1
            %         subplot(1,2,2)
            x1 = xtotal(pipe_nodes(ip,1),1);
            x2 = xtotal(pipe_nodes(ip,2),1);
            y1 = xtotal(pipe_nodes(ip,1),2);
            y2 = xtotal(pipe_nodes(ip,2),2);
            T1 = Tn(pipe_nodes(ip,1));
            T2 = Tn(pipe_nodes(ip,2));
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
            
            if ip == linkPipe
               plot(xtotal(pipe_nodes(ip,1),1), xtotal(pipe_nodes(ip,1),2),'ko','markerfacecolor','k')
               hold on
               plot(xtotal(pipe_nodes(ip,2),1), xtotal(pipe_nodes(ip,2),2),'ko','markerfacecolor','k')
            end
            
            if (nn<20)
                plot(xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
            end      
            
            if ismember(pipe_nodes(ip,1),qin_node) == 1
                plot(xtotal(pipe_nodes(ip,1),1),xtotal(pipe_nodes(ip,1),2),'co','markerfacecolor','c')
            elseif ismember(pipe_nodes(ip,2),qin_node) == 1
                plot(xtotal(pipe_nodes(ip,2),1),xtotal(pipe_nodes(ip,2),2),'co','markerfacecolor','c')
            elseif ismember(pipe_nodes(ip,1),qout_node) == 1
                plot(xtotal(pipe_nodes(ip,1),1),xtotal(pipe_nodes(ip,1),2),'ro','markerfacecolor','r')
            elseif ismember(pipe_nodes(ip,2),qout_node) == 1
                plot(xtotal(pipe_nodes(ip,2),1),xtotal(pipe_nodes(ip,2),2),'ro','markerfacecolor','r')
            elseif ismember(pipe_nodes(ip,1),linkPipe) == 1
                plot(xtotal(pipe_nodes(ip,1),1),xtotal(pipe_nodes(ip,1),2),'ko','markerfacecolor','k')
            elseif ismember(pipe_nodes(ip,2),linkPipe) == 1
                plot(xtotal(pipe_nodes(ip,2),1),xtotal(pipe_nodes(ip,2),2),'ko','markerfacecolor','k')
            end
            
        end
    end
    hcb = colorbar;
    hcb.Label.String = 'Temperature';
    title(hcb,'T(^oC)')
end


       
            
    


        
        
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

% if size(x,2) == 2 | (size(x,2) == 3 & numel(unique([xo(:,3);x(:,3)]))==1)

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
    if (nn<20) 
        plot(xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
    end
    x1 = xtotal(pipe_nodes(:,1),1);
    x2 = xtotal(pipe_nodes(:,2),1);
    y1 = xtotal(pipe_nodes(:,1),2);
    y2 = xtotal(pipe_nodes(:,2),2);
    dx2 = 0.5*(x2-x1); 
    dy2 = 0.5*(y2-y1);
    q2=quiver(x1(:),y1(:),dx2(:),dy2(:),0);
    q2.ShowArrowHead='on';
    q2.Color='black';
    z1 = 0;
    z2 = 0;
    drel=d/dmax*dplot;
%     for ip = 1:np
%         x1 = xtotal(pipe_nodes(ip,1),1);
%         x2 = xtotal(pipe_nodes(ip,2),1);
%         y1 = xtotal(pipe_nodes(ip,1),2);
%         y2 = xtotal(pipe_nodes(ip,2),2);
%         z1 = 0;
%         z2 = 0;
%         x = [x1 x2];
%         y = [y1 y2];
%         z = [z1 z2];
%         col = [Q(ip) Q(ip)];
%         surface([x;x],[y;y],[z;z],[col;col],... 
%                 'facecol','no',... 
%                 'edgecol','interp',...
%                 'linew',d(ip)/dmax*dplot);
%         if (nn<20) 
%             plot(xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
%         end
    for ip = 1:np
        x = [x1(ip) x2(ip)];
        y = [y1(ip) y2(ip)];
        z = [z1 z2];
        col = [Q(ip) Q(ip)];
        surface([x;x],[y;y],[z;z],[col;col],... 
                'facecol','no',... 
                'edgecol','interp',...
                'linew',drel(ip));
    end
    hcb = colorbar;
    title(hcb,'Q(m^3/sec)')
    hcb.Label.String = 'Volumetric Flow Rate, Q';
    view(2)
    hold off
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Case 2 -  3D with z-separation provided
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% elseif size(x,2) == 3 & numel(unique([xo(:,3);x(:,3)]))~=1
%     disp('Separate flow')
%     
%     seamDepths = sort(unique(xtotal(:,3)),'ascend');
%     Z1 = xtotal(pipe_nodes(:,1),3);
%     Z2 = xtotal(pipe_nodes(:,2),3);
%     lowerSeam = find(Z1 == Z2 & Z1 == seamDepths(1));
%     upperSeam = find(Z1 == Z2 & Z1 == seamDepths(2)); 
%     linkPipe = find(Z1 ~= Z2);
%     
%     figure(2), clf
%     axis equal
%     hold on 
%     grid on
%     colormap(colourBar)
%     minQ = min(Q);
%     maxQ = max(Q);
%     dQ = maxQ-minQ;
%     if (abs(dQ/maxQ)<0.01)
%         eps = abs(0.01*maxQ);
%     else
%         eps = 0;
%     end
%     %caxis([minQ-eps maxQ+eps]);
%     caxis([maxQ*1e-3 maxQ+eps]);
%     set(gca,'ColorScale','log')
%     for ip = 1:np
%         if ismember(ip,[lowerSeam; linkPipe]) == 1              
%             x1 = xtotal(pipe_nodes(ip,1),1);
%             x2 = xtotal(pipe_nodes(ip,2),1);
%             y1 = xtotal(pipe_nodes(ip,1),2);
%             y2 = xtotal(pipe_nodes(ip,2),2);
%             z1 = 0;
%             z2 = 0;
%             x = [x1 x2];
%             y = [y1 y2];
%             z = [z1 z2];
%             col = [Q(ip) Q(ip)];
%             surface([x;x],[y;y],[z;z],[col;col],...
%                 'facecol','no',...
%                 'edgecol','interp',...
%                 'linew',d(ip)/dmax*dplot);
% 
%             if ip == linkPipe
%                plot(xtotal(pipe_nodes(ip,1),1), xtotal(pipe_nodes(ip,1),2),'kx','markerfacecolor','k')
%                hold on
%                plot(xtotal(pipe_nodes(ip,2),1), xtotal(pipe_nodes(ip,2),2),'kx','markerfacecolor','k')
%             end
%             
%             if (nn<20)
%                 plot(xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
%             end
%             
%             %%%% Plot inflow and outflow locations
%             if ismember(pipe_nodes(ip,1),qin_node) == 1
%                 plot(xtotal(pipe_nodes(ip,1),1),xtotal(pipe_nodes(ip,1),2),'co','markerfacecolor','c')
%             elseif ismember(pipe_nodes(ip,2),qin_node) == 1
%                 plot(xtotal(pipe_nodes(ip,2),1),xtotal(pipe_nodes(ip,2),2),'co','markerfacecolor','c')
%             elseif ismember(pipe_nodes(ip,1),qout_node) == 1
%                 plot(xtotal(pipe_nodes(ip,1),1),xtotal(pipe_nodes(ip,1),2),'ro','markerfacecolor','r')
%             elseif ismember(pipe_nodes(ip,2),qout_node) == 1
%                 plot(xtotal(pipe_nodes(ip,2),1),xtotal(pipe_nodes(ip,2),2),'ro','markerfacecolor','r')
%                 
%             %%%% Plot link pipe locations
%             elseif ismember(pipe_nodes(ip,1),linkPipe) == 1
%                 plot(xtotal(pipe_nodes(ip,1),1),xtotal(pipe_nodes(ip,1),2),'kx','markerfacecolor','k')
%             elseif ismember(pipe_nodes(ip,2),linkPipe) == 1
%                 plot(xtotal(pipe_nodes(ip,2),1),xtotal(pipe_nodes(ip,2),2),'kx','markerfacecolor','k')
%             end
%         end
%     end 
%     
%     hcb = colorbar;
%     title(hcb,'Q(m^3/sec)')
%     hcb.Label.String = 'Volumetric Flow Rate, Q';
%     view(2)
% 
% 
%     figure(5), clf
%     axis equal
%     hold on 
%     grid on
%     colormap(colourBar)
%     minQ = min(Q);
%     maxQ = max(Q);
%     dQ = maxQ-minQ;
%     if (abs(dQ/maxQ)<0.01)
%         eps = abs(0.01*maxQ);
%     else
%         eps = 0;
%     end
%     %caxis([minQ-eps maxQ+eps]);
%     caxis([maxQ*1e-3 maxQ+eps]);
%     set(gca,'ColorScale','log')
%     for ip = 1:np
%         if ismember(ip,[upperSeam; linkPipe]) == 1
%             x1 = xtotal(pipe_nodes(ip,1),1);
%             x2 = xtotal(pipe_nodes(ip,2),1);
%             y1 = xtotal(pipe_nodes(ip,1),2);
%             y2 = xtotal(pipe_nodes(ip,2),2);
%             z1 = 0;
%             z2 = 0;
%             x = [x1 x2];
%             y = [y1 y2];
%             z = [z1 z2];
%             col = [Q(ip) Q(ip)];
%             surface([x;x],[y;y],[z;z],[col;col],...
%                 'facecol','no',...
%                 'edgecol','interp',...
%                 'linew',d(ip)/dmax*dplot);
%             
%             if ip == linkPipe
%                plot(xtotal(pipe_nodes(ip,1),1), xtotal(pipe_nodes(ip,1),2),'ko','markerfacecolor','k')
%                hold on
%                plot(xtotal(pipe_nodes(ip,2),1), xtotal(pipe_nodes(ip,2),2),'ko','markerfacecolor','k')
%             end
%             
%             if (nn<20)
%                 plot(xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
%             end      
%             
%             if ismember(pipe_nodes(ip,1),qin_node) == 1
%                 plot(xtotal(pipe_nodes(ip,1),1),xtotal(pipe_nodes(ip,1),2),'co','markerfacecolor','c')
%             elseif ismember(pipe_nodes(ip,2),qin_node) == 1
%                 plot(xtotal(pipe_nodes(ip,2),1),xtotal(pipe_nodes(ip,2),2),'co','markerfacecolor','c')
%             elseif ismember(pipe_nodes(ip,1),qout_node) == 1
%                 plot(xtotal(pipe_nodes(ip,1),1),xtotal(pipe_nodes(ip,1),2),'ro','markerfacecolor','r')
%             elseif ismember(pipe_nodes(ip,2),qout_node) == 1
%                 plot(xtotal(pipe_nodes(ip,2),1),xtotal(pipe_nodes(ip,2),2),'ro','markerfacecolor','r')
%             elseif ismember(pipe_nodes(ip,1),linkPipe) == 1
%                 plot(xtotal(pipe_nodes(ip,1),1),xtotal(pipe_nodes(ip,1),2),'ko','markerfacecolor','k')
%             elseif ismember(pipe_nodes(ip,2),linkPipe) == 1
%                 plot(xtotal(pipe_nodes(ip,2),1),xtotal(pipe_nodes(ip,2),2),'ko','markerfacecolor','k')
%             end
%             
%         end
%     end
%     
%     hcb = colorbar;
%     title(hcb,'Q(m^3/sec)')
%     hcb.Label.String = 'Volumetric Flow Rate, Q';
%     view(2)
%    
% end    
    
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
    title(hcb,'H(m)');
    view(2);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%% FIGURE 5 - Thermal drawdown radii %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% % JMC appears to be glitched and causing warning in plotting lib
% figure(5), clf
%     axis equal
%     hold on 
%     grid on
%     colormap(colourBar)
%     minr = min(rp);
%     maxr = max(rp);
%     dr = maxr-minr;
%     if (abs(dr/maxr)<0.01)
%         eps = abs(0.01*maxr);
%     else
%         eps = 0;
%     end
%     %caxis([minQ-eps maxQ+eps]);
%     caxis([maxr*1e-3 maxr+eps]);
%     set(gca,'ColorScale','log')
%     for ip = 1:np
%         x1 = xtotal(pipe_nodes(ip,1),1);
%         x2 = xtotal(pipe_nodes(ip,2),1);
%         y1 = xtotal(pipe_nodes(ip,1),2);
%         y2 = xtotal(pipe_nodes(ip,2),2);
%         z1 = 0;
%         z2 = 0;
%         x = [x1 x2];
%         y = [y1 y2];
%         z = [z1 z2];
%         col = [rp(ip) rp(ip)];
%         surface([x;x],[y;y],[z;z],[col;col],... 
%                 'facecol','no',... 
%                 'edgecol','interp',...
%                 'linew',d(ip)/dmax*dplot);
%         if (nn<20) 
%             plot(xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
%         end
%     end
%     hcb = colorbar;
%     title(hcb,'r(m)');
%     hcb.Label.String = 'Thermal drawdown radius, r'; % Glitch happens due to this line
%     view(2);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%% FIGURE 6 - Reynolds Number %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
figure(6), clf
    axis equal
    hold on 
    grid on
    colormap(colourBar)
    minRe = min(Re);
    maxRe = max(Re);
    dRe = maxRe-minRe;
    if (abs(dRe/maxRe)<0.01)
        eps = abs(0.01*maxRe);
    else
        eps = 0;
    end
    %caxis([minQ-eps maxQ+eps]);
    caxis([maxRe*1e-3 maxRe+eps]);
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
        col = [Re(ip) Re(ip)];
        surface([x;x],[y;y],[z;z],[col;col],... 
                'facecol','no',... 
                'edgecol','interp',...
                'linew',d(ip)/dmax*dplot);
        if (nn<20) 
            plot(xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
        end
    end
    hcb = colorbar;
    title(hcb,'Reynold Number');
    hcb.Label.String = 'Re';
    view(2);
    
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
end
