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
% 20210630 - added testbank
% 20210628 - added igeom 103 for grid with multiple extraction schemes
% 20210609 - added igeom 101 and 102 to test prescribed in/outflow
% 20210518 - merging different codes into a signle master version   
% 20190628 - code split up in separate subfunctions
% 
% Jeroen van Hunen

% More (debug?) output? --> Set verbose to 1.
verbose = 1;

% Geometry used for calculation (not used if testbank!=0):
igeom = 103;

% Testbank options to check if the code was broken during recent update: 
testbank = 0; %  0 = no testing, use igeom above
%             % -1 = create testbank benchmark results 
%             %  1 = testing your latest code against testbank results
if testbank == 0
    ntests = 1;
    alltests = igeom;
    disp (['mineheat: running + plotting geometry ',num2str(igeom),'.'])
elseif testbank == -1 || testbank == 1
    ntests = 10;
    alltests  = zeros(ntests,1);
    alltests  = [1 2 3 4 5 6 7 101 102 103];
    disp (['mineheat: Testbank: testing geometries ',num2str(alltests),'.'])
end

for igeom = alltests
    % read in geometries:
    [nn, no, np, A12, A10, xo, x, d, Ho, q] = geometries(igeom);

    % Set constant physical and model input parameters:
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
    v      = Q ./ (pi*(d/2).^2);

    [Tn Tp]= mine_heat(t, d, L, Q, v, np, nn, no, Tf_ini, k_r, Cp_r, rho_r,...
        Tr, npipes, node_pipes_in, node_pipes_out, pipe_nodes,xtotal);
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

% plot results: 
if testbank == 0  % only plot results when not performing testbank tasks:
    mine_plots (igeom, xo, x, d, np, nn, pipe_nodes, Tp, Tn, Q, H, Ho)
end