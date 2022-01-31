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
% Jeroen van Hunen

% More (debug?) output? --> Set verbose to 1.
verbose = 0;

% Set (default) constant physical and model input parameters
Tf_ini = 1;        % water inflow temperature (degC) 
nyrs   = 1;        % flow duration (yrs)
k_r    = 3.0;      % thermal conductivity
Cp_r   = 900.0;    % heat capacity
rho_r  = 2300.0;   % density
Tr     = 25.0;     % Initial rock temperature (degC)
d_set   = 4;        % Pipe diameter (m)

% Geometry used for calculation (not used if testbank!=0):
igeom = 8;
alltests = igeom;

% set flowrate (m3/s) or ((m3/h)/3600)
qset   = 67/3600;  

% Set inflow/outflow node locations:
n_flows = 1; % specify number of flows on mine system
% 2 flow system possible
q_in  = cell(n_flows,1);
q_out = cell(n_flows,1);

% selects in and outflow position based on number of flows 
% - current limit is 4 flows
switch n_flows
    case 1
        q_in{1}=1098; q_out{1}=2512;
        q_in{1}  = 1;
        q_out{1} = 10;
    case 2
        q_in{1}  = 1;
        q_out{1} = 71;
        q_in{2}  = 10;
        q_out{2} = 140;
    case 3
        q_in{1}  = 1;
        q_out{1} = 3;
        q_in{2}  = 5;
        q_out{2} = 6;
        q_in{3}  = 7;
        q_out{3} = 10;
    case 4
        q_in{1}  = 1;
        q_out{1} = 71;
        q_in{2}  = 10;
        q_out{2} = 140;
        q_in{3}  = 141;
        q_out{3} = 149;
        q_in{4}  = 5;
        q_out{4} = 35;
end

% Testbank options to check if the code was broken during recent update: 
testbank = 0 ; %  0 = no testing, use igeom above
              % -1 = create testbank benchmark results 
              %  1 = testing your latest code against testbank results
if testbank == 0
    ntests = 1;
    alltests = igeom;
    disp (['mineheat: running + plotting geometry ',num2str(igeom),'.'])
elseif testbank == -1 || testbank == 1
    ntests = 8 ;
    igeomarray  = [1 2 3 4 5 101 102 103];
    disp (['mineheat: Testbank: testing geometries ',num2str(igeomarray),'.'])
    % set a default set of physical parameters: 
    Tf_ini = 3;        % water inflow temperature (degC) 
    nyrs   = 1;        % flow duration (yrs)
    k_r    = 3.0;      % thermal conductivity
    Cp_r   = 900.0;    % heat capacity
    rho_r  = 2300.0;   % density
    Tr     = 25.0;     % Initial rock temperature (degC)
    d_set   = 4;        % Pipe diameter (m)
    
    % Set inflow/outflow node locations:
    % Testbank done with 1 flow system
    n_flows = 1;
    q_in  = cell(n_flows,1);
    q_out = cell(n_flows,1);
    % Sets in and ouflow node locations
    q_in{1}  = 1;
    q_out{1} = 10;
end

% parameter sensitivity tests
% 1 = duration of extraction/reinjection
paramsenstest = 0;
if paramsenstest > 0  % set up serie of parameter sensitivity tests
    switch paramsenstest
        case paramsenstest == 1 % duration
            nyrs_array = [0.125 0.25 0.5 1 2 4 8 16 32 64 128 256 512 1024 2048 4096 9192];
            nyrs_array = 2.^[-10:30];
            ntests = length(nyrs_array);
            nyrs_result = zeros(1,ntests);
    end
end

if testbank ~= 0 && paramsenstest ~=0
    error('Error, cannot use testbank and paramsenstest simultaneously')
end

for irun = 1:ntests
    
    if testbank == -1 || testbank == 1
        igeom = igeomarray(irun);
    end
    if paramsenstest > 0  % set up serie of parameter sensitivity tests
        if paramsenstest == 1  % test different model times
            nyrs = nyrs_array(irun); 
        end
    end
    % read in geometries:
    %tic
    [nn, no, np, A12, A10, xo, x, Ho, q, idiagn] = geometries(igeom,qset,q_in,q_out);
    %sprintf('mine array setup')
    %toc
    
    % Array with diameter for each pipe
    d = d_set*ones(np,1);
    
    % Array with start & end node of each pipe:
    pipe_nodes  = zeros(np,2);  % array to store start & end node of each pipe
                                % note the 'global' node numbering, including
                                %    fixed and free head nodes
    A102 = [A10 A12];           % merges table of fixed (A10) and unknown (A12) nodes
    [row,col] = find(A102==-1); % node with -1 indicates one end point of pipe
    pipe_nodes(row,1) = col;    % store that node nr in pipe_nodes array
    [row,col] = find(A102==1);  % node with 1 indicates the other end point
    pipe_nodes(row,2) = col;    % store that node nr in pipe_nodes array

    % Pipe lengths: 
    L   = zeros(np,1);
    xtotal = [xo;x];
    p1 = pipe_nodes(:, 1);
    p2 = pipe_nodes(:, 2);
    x1 = xtotal(p1,:);
    x2 = xtotal(p2,:);
    dx = x2-x1;
    L  = sqrt(dx(:,1).^2+dx(:,2).^2);  % z-distance not in here yet
    
    % Initial rock temperature (in degC):   
    Tin    = Tf_ini*ones(np,1);
    
%     disp('mineflow') % update where code is running on terminal
    % Calculate flow through pipe system:
    %tic
    [H Q]  = mineflow(nn, no, np, x, xo, A12, A10, Ho, q, L, d);
    %sprintf('mine flow')
    %toc
    %%% Setup pipe flow arrays:
    %tic
    [pipe_nodes npipes node_pipes_out node_pipes_in Q] ...
           = mine_array_setup(np, nn, no, A10, A12, pipe_nodes, q, Q);
    %sprintf('mine array setup')
    %toc

    %%% Calculate temperature of pipe system:
    % set time at 'nyear' years:
    t      = 3600*24*365*nyrs;
    v      = Q ./ (pi*(d/2).^2);
    
%     disp('mine_heat') % update where code is running on terminal
    %tic
    [Tn Tp]= mine_heat(t, d, L, Q, v, np, nn, no, Tf_ini, k_r, Cp_r, rho_r,...
        Tr, npipes, node_pipes_in, node_pipes_out, pipe_nodes,xtotal);
    %sprintf('mine_heat')
    %toc
    % Output of routine mine_heat: 
    % - Tn, ordered as [x0;x] (i.e. first all fixed-head nodes, then the others
    % - Tp, as np-by-2 array, with Tp(:,1)=inflow T of pipe, and Tp(:,2) the
    %      outflow T
    
    % Store testbank results
    if testbank ~= 0
        testbank_eval(testbank, H, Q, Tn, Tp, igeom)
    end
    if paramsenstest > 0  % set up serie of parameter sensitivity tests
        if paramsenstest == 1  % test different model times
            nyrs_result(irun) = Tn(idiagn);
        end
    end
    %pause
end

% plot results: 
if testbank == 0 && paramsenstest == 0 % only plot results when not performing testbank tasks:
    disp('Plotting... Please wait');
    %tic
    mine_plots (igeom, xo, x, d, np, nn, pipe_nodes, Tp, Tn, Q, H, Ho, Tr, Tf_ini)
    %sprintf('mine_plots')
    %toc
end
if(paramsenstest ~=0)
    if paramsenstest == 1
        figure(1)
            semilogx(nyrs_array, nyrs_result, 'o-')
            xlabel('t(years)')
            ylabel('T_{out}(^oC)')
            print(gcf,'paramtest1.png','-dpng','-r300');
    end
end
