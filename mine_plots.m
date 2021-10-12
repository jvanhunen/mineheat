function Tout = mine_plots (igeom, xo, x, d, np, nn, pipe_nodes, Tp, Tn, Q, H, Ho, Tr)
% 
% This routine plots temperature T, flow Q and fluid pressure (hydraulic
% head ) H distributions across the mine network.
%
% Version 20210630 Jeroen van Hunen

dplot = 2;   % Thickness of pipe segments in plot    
figure(1), clf
    axis equal
    xlabel('x(m)')
    ylabel('y(m)')
    xtotal = [xo; x];
    dmax = max(d);
    %subplot(3,1,1)
        grid on
        hold on 
        colormap(jet)
        caxis([min(min(Tp)) max(max(Tp))]);
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
        hcb = colorbar;
        title(hcb,'T(^oC)')
        %view(2)
        
figure(2), clf
    axis equal
    hold on 
    grid on
    colormap(jet)
    minQ = min(Q);
    maxQ = max(Q);
    dQ = maxQ-minQ;
    if (abs(dQ/maxQ)<0.01)
        eps = abs(0.01*maxQ);
    else
        eps = 0;
    end
    caxis([minQ-eps maxQ+eps]);
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
    view(2)
    
figure(3), clf
    axis equal
    grid on
    hold on 
    colormap(jet)
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
    
if igeom ==1 || igeom==101 || igeom==102
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
