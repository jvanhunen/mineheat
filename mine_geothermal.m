clear

%%% mine_geothermal
% 
% Code to calculate flow and T-distribution through mine system
% Flow based on:  
% - Todini & Pilati, 1988, A gradient method for the analysis of pipe networks
% - also used in EPANET2 software
% Temperature distribution base on:
% - Rodriguez & Diaz, 2009
% - benchark in Loredo et al, 2017
% 
% Version: 
% 20210609 - added igeom 101 and 102 to test prescribed in/outflow
% 20210518 - merging different codes into a signle master version   
% 20190628 - code split up in separate subfunctions
% 
% Jeroen van Hunen

% More (debug?) output? --> Set verbose to 1.
verbose = 1;

% To check if the code was broken during any recent updates, several testbank options are available: 
% 0 = no testing
igeom = 5;
testbank = 0; %  0 = no testing 
%             % -1 = create to testbank results 
%             %      (NB do NOT use to check your newest code version!)
%             %  1 = testing your latest results against testbank results
if testbank == 0
    ntests = 1;
    alltests = igeom;
    disp (['mineheat: running + plotting geometry ',num2str(igeom),'.'])
elseif testbank == -1 || testbank == 1
    ntests = 9;
    alltests  = zeros(ntests,1);
    alltests  = [1 2 3 4 5 6 7 101 102];
    disp (['mineheat: Testbank: testing geometries ',num2str(alltests),'.'])
end

for igeom = alltests
    % read in geometries:
    [nn, no, np, A12, A10, xo, x, d, Ho, q] = geometries(igeom);
    r = d/2;

    % Set constant input parameters:
    Tf_ini = 3;        % water inflow temperature (degC) 
    nyrs   = 1;        % flow duration (yrs)
    k_r    = 3.0;      % thermal conductivity
    Cp_r   = 900.0;    % heat capacity
    rho_r  = 2300.0;   % density
    Tr     = 25.0;     % Initial rock temperature (degC)

    % Array with start & end node of each pipe:
    pipe_nodes  = zeros(np,2);  % array to store start & end node of each pipe
                                % note the 'global' node numbering, including
                                %    fixed and free head nodes
    A102 = [A10 A12];           % merges table of fixed (A10) and unknown (A12) nodes
    [row,col] = find(A102==-1); % node with -1 indicates one end point of pipe
    pipe_nodes(row,1) = col;    % store that node nr in pipe_nodes array
    [row,col] = find(A102==1);  % node with 1 indicates the other end point
    pipe_nodes(row,2) = col;    % store that node nr in pipe_nodes array
    %pipe_nodes

    % Pipe lengths: 
    L   = zeros(np,1);
    xtotal = [xo;x];
    p1 = pipe_nodes(:, 1);
    p2 = pipe_nodes(:, 2);
    x1 = xtotal(p1,:);
    x2 = xtotal(p2,:);
    dx = x2-x1;
    L  = sqrt(dx(:,1).^2+dx(:,2).^2);

    % Initial rock temperature (in degC):   
    Tin    = Tf_ini*ones(np,1);

    % Calculate flow through pipe system:
    [H Q]  = mineflow(nn, no, np, x, xo, A12, A10, Ho, q, L, d);

    %%% Setup pipe flow arrays:
    [pipe_nodes npipes node_pipes_out node_pipes_in Q] ...
           = mine_array_setup(np, nn, no, A10, A12, pipe_nodes, q, Q);

    %%% Calculate temperature of pipe system:
    % set time at 'nyear' years:
    t      = 3600*24*365*nyrs;
    v      = Q ./ (pi*r.^2);

    [Tn Tp]= mine_heat(t, r, L, Q, v, np, nn, no, Tf_ini, k_r, Cp_r, rho_r,...
        Tr, npipes, node_pipes_in, node_pipes_out, pipe_nodes,xtotal,d);
    % Output of routine mine_heat: 
    % - Tn, ordered as [x0;x] (i.e. first all fixed-head nodes, then the others
    % - Tp, as np-by-2 array, with Tp(:,1)=inflow T of pipe, and Tp(:,2) the
    %      outflow T
    
    % Store testbank results
    if testbank == -1
        savefile = ['testbank/testbank_' num2str(igeom) '.mat']
        Hstore = H; 
        Qstore = Q;
        Tnstore = Tn;
        Tpstore = Tp;
        save(savefile,'Hstore', 'Qstore', 'Tnstore', 'Tpstore')
    elseif testbank == 1
        loadfile = ['testbank/testbank_' num2str(igeom) '.mat'];
        if verbose
            disp (['   --> Tested geometry ',num2str(igeom),':'])
        end
        load(loadfile,'Hstore', 'Qstore', 'Tnstore', 'Tpstore')
        Hdiff = H - Hstore;
        Qdiff = Q - Qstore;
        Tndiff = Tn - Tnstore;
        Tpdiff = Tp - Tpstore;
        if (max(Hdiff) > 0 | max(Qdiff) > 0 | max(Tndiff) > 0 | max(Tpdiff) > 0)
            disp (['       failed: Differences in H, Q, Tn, and Tp:'])
            Hdiff
            Qdiff
            Tndiff
            Tpdiff
        else
            disp ('       passed')
        end
    end
end

% PLOT RESULTS:
% =============
if testbank == 0  % only plot results when not performing testbank tasks:
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
                hcb = colorbar;
                title(hcb,'T(^oC)')
                %view(2)
            end
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
            hcb = colorbar;
            title(hcb,'Q(m^3/sec)')
            view(2)
        end

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
            hcb = colorbar;
            title(hcb,'H(m)')
            view(2)
        end
    
    if igeom ==1 | igeom==101 | igeom==102
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
    
    disp (['Max node temperature = ', num2str(max(abs(Tn))), ' degC'])
    disp (['Max flow rate = ', num2str(1e3*max(abs(Q))), ' litres/sec'])
end