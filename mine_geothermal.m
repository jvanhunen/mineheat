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
% 20210518 - merging different codes into a signle master version   
% 20190628 - code split up in separate subfunctions
% 
% Jeroen van Hunen

% Set constant input parameters:
igeom  = 5;        % pipe geometry option
Tf_ini = 3;        % water inflow temperature (degC) 
nyrs   = 1;        % flow duration (yrs)
head   = 1e-11;     % hydraulic head loss through mine (m). e.g. 6.3e-12 
k_r    = 3.0;      % thermal conductivity
Cp_r   = 900.0;    % heat capacity
rho_r  = 2300.0;   % density
Tr     = 25.0;     % Initial rock temperature (degC)

% Set mine geometry:
if igeom==1
    % linear pipesystem:
    [nn, no, np, A12, A10, xo, x, d] = geometry1();
elseif igeom==2
    % dual, parallel pipesystem:
    [nn, no, np, A12, A10, xo, x, d] = geometry2();
elseif igeom==3
    % partly dual, parallel pipesystem:
    [nn, no, np, A12, A10, xo, x, d] = geometry3();
elseif igeom==4
    % small grid:
    [nn, no, np, A12, A10, xo, x, d] = geometry4();
elseif igeom==5
    % large grid (diss Marijn Huis):
    n  = 31;   % grid width (number of nodes wide)
    m  = 11;   % grid height (number of nodes high)
    l1 = 100;  % length of horizontal pipes
    l2 = 100;  % length of vertical pipes
    [nn, no, np, A12, A10, xo, x, p_output, d] = geometry_grid(n , m, l1, l2);
elseif igeom==6
    % Louisa model (ESII 19/20): 
    diam = 4.0;
    [nn, no, np, A12, A10, xo, x, d] = louisa_model(diam);
elseif igeom==7
    % Hawthorn model (ESII 20/21): 
    igeomH = 1;
    optionH = 1;
    diam = 4.0;
    [nn, no, np, A12, A10, xo, x, d] = hawthorn_model(diam,igeomH,optionH);
end
r      = d/2;

% Array with start & end node of each pipe:
pipe_nodes  = zeros(np,2);   % array to store start & end node of each pipe
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

% set fixed hydraulic heads:
Ho     = zeros(no,1);
Ho(1)  = head;

% Initial rock temperature (in degC):   
Tin    = Tf_ini*ones(np,1);

% Calculate flow through pipe system:
[H Q]  = mineflow_mod(nn, no, np, x, xo, A12, A10, Ho, L, d);

%%% Setup pipe flow arrays:
[pipe_nodes npipes node_pipes_out node_pipes_in weighted_flow_in Q] ...
       = mine_array_setup(np, nn, no, A10, A12, pipe_nodes, Q);

%%% Calculate temperature of pipe system:
% set time at 'nyear' years:
t      = 3600*24*365*nyrs;
v      = Q ./ (pi*r.^2);
[Tn Tp]= mine_heat(t, r, L, v, np, nn, no, Tf_ini, k_r, Cp_r, rho_r,...
    Tr, npipes, node_pipes_out, pipe_nodes, weighted_flow_in,xtotal,d);

% Plotting: 
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
%view(3)
drawnow

disp (' ')
disp ('Output temperature:')
Tout = Tn(2);
disp ('Flow rate, Litres per second:')
Qout = Q(1); %(Q(96)+Q(97))*10^3;