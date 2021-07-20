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
% 20210720 - started adding parameter sensitivity tests
%            put mine plots in separate function mine_plots
%            put testbank procedures in separate function testbank_eval
% 20210630 - added testbank
% 20210628 - added igeom 103 for grid with multiple extraction schemes
% 20210609 - added igeom 101 and 102 to test prescribed in/outflow
% 20210518 - merging different codes into a signle master version   
% 20190628 - code split up in separate subfunctions
% 
% Jeroen van Hunen

% More (debug?) output? --> Set verbose to 1.
verbose = 0;

% Set (default) constant physical and model input parameters:
Tf_ini = 3;        % water inflow temperature (degC) 
nyrs   = 30;        % flow duration (yrs)
k_r    = 3.0;      % thermal conductivity
Cp_r   = 900.0;    % heat capacity
rho_r  = 2300.0;   % density
Tr     = 25.0;     % Initial rock temperature (degC)

% Geometry used for calculation (not used if testbank!=0):
igeom = 103;
alltests = igeom;

% Testbank options to check if the code was broken during recent update: 
testbank = 1; %  0 = no testing, use igeom above
%             % -1 = create testbank benchmark results 
%             %  1 = testing your latest code against testbank results
if testbank == 0
    ntests = 1;
    alltests = igeom;
    disp (['mineheat: running + plotting geometry ',num2str(igeom),'.'])
elseif testbank == -1 || testbank == 1
    ntests = 10;
    igeomarray  = [1 2 3 4 5 6 7 101 102 103];
    disp (['mineheat: Testbank: testing geometries ',num2str(igeomarray),'.'])
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
    [nn, no, np, A12, A10, xo, x, d, Ho, q, idiagn] = geometries(igeom);

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
    if testbank ~= 0
        testbank_eval(testbank, H, Q, Tn, Tp, igeom)
    end
    if paramsenstest > 0  % set up serie of parameter sensitivity tests
        if paramsenstest == 1  % test different model times
            nyrs_result(irun) = Tp(idiagn);
        end
    end
end

% plot results: 
if testbank == 0 && paramsenstest == 0 % only plot results when not performing testbank tasks:
    mine_plots (igeom, xo, x, d, np, nn, pipe_nodes, Tp, Tn, Q, H, Ho)
end
if(paramsenstest ~=0)
    if paramsenstest == 1
        figure(1), clf
            semilogx(nyrs_array, nyrs_result, 'o-')
    end
end
