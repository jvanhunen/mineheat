clear
clc
load('inferno.mat');
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% PRE-PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% For CA users, interaction with MATLAB files should be no more than
%%% setting values to variables in the PRE-PROCESSING section

% Geometry used for calculation (not used if testbank!=0):
igeom = 11; %'UserDefinedGeometry-CommandLinePrompts'; 
alltests = igeom; 

% Testbank
testbank = 0; %%%  0 = no testing, use igeom above
              %%% -1 = create testbank benchmark results 
              %%%  1 = testing your latest code against testbank results

% Material physical properties options
physical_propertiesFlag = 2;       %%% 0 - User specified + command prompt
                                   %%% 1 - User specified - define in code
                                   %%% 2 - Default properties
                                   %%% 3 - Probabaistic properties (PLACEHOLDER)
                            
                                 
% Generate output type
figureFlag = 1;       %%% 0 - Print summary results file
                      %%% 1 - Plot maps
                      %%% 2 - Print summary results files and
                      %%%     plot maps  - TODO

savePrompt = 1;       %%% 0 - Prints summary results to command line, but does not generate text file or prompt
                      %%%     saving by default. Use if you know what you are doing with MATLAB(!) and want flexible
                      %%%     control on saving
                      %%%     
                      %%% 1 - Pop-up windows to allow user to save model results at end of run
                      %%%     Currently simplistic functionality - needs to be saved on a run-by-run basis, no capability 
                      %%%     to create summaries for multi-scenario runs as of yet  (TODO)
                                   
switch physical_propertiesFlag

    case  0   %%% 0 - User specified + command prompt
        
       %%%% Pop-up window file selection
       AskUser = msgbox('Select physical properties file (.csv)');
       waitfor(AskUser)
       [UserFile, path] = uigetfile('*.csv');
       PhysicalProperties = readtable(fullfile(path, UserFile));

       % Set constant physical and model input parameters from user selected
       % file
       k_r    = PhysicalProperties.k_r;      % thermal conductivity     [
       Cp_r   = PhysicalProperties.Cp_r;     % heat capacity            [
       rho_r  = PhysicalProperties.rho_r;    % density                  [kg m^-3]
       Tf_ini = PhysicalProperties.Tf_ini;   % water inflow temperature [oC]
       Tr     = PhysicalProperties.Tr;       % Initial rock temperature [oC]
       d_set  = PhysicalProperties.d_set;    % Pipe diameter            [m]
       


   case 1     %%% 1 - User specified - write a .csv file containing properties

       PhysicalProperties = readtable('PhysicalProperties.csv');

       % Set (default) constant physical and model input parameters
       k_r    = PhysicalProperties.k_r;      % thermal conductivity     [
       Cp_r   = PhysicalProperties.Cp_r;     % heat capacity            [
       rho_r  = PhysicalProperties.rho_r;    % density                  [kg m^-3]
       Tf_ini = PhysicalProperties.Tf_ini;   % water inflow temperature [oC]
       Tr     = PhysicalProperties.Tr;       % Initial rock temperature [oC]
       d_set  = PhysicalProperties.d_set;    % Pipe diameter            [m]


   case 2     %%% 2 - Default properties

       PhysicalProperties = readtable('DefaultPhysicalProperties.csv');
       k_r    = PhysicalProperties.k_r;      % thermal conductivity     [
       Cp_r   = PhysicalProperties.Cp_r;     % heat capacity            [
       rho_r  = PhysicalProperties.rho_r;    % density                  [kg m^-3]
       Tf_ini = PhysicalProperties.Tf_ini;   % water inflow temperature [oC]
       Tr     = PhysicalProperties.Tr;       % Initial rock temperature [oC]
       d_set  = PhysicalProperties.d_set;    % Pipe diameter            [m]
       nyrs   = 1;                           % flow duration (yrs) - for user convenience

   case 3      %%% 3 - Probabaistic properties

       % This is not developed in any way, it is just a place holder in 
       % order to allow random_input_mod.m to be included as an option at a 
       % later date

       %       [kr_in, Cp_in, rho_in, diameter_in, Tr_in] = random_input_mod()

       % Modifications to this script could include
       %   - modification to assumed distributions currently unifrom
       %   - allow random_input_mod.m to take mean and standard deviaiton as
       %     arguments
       %   - Take in correlation matrices to generate correlated random variables
       %   - Adopt latin hypersquare sampling to improv efficiency of sampling

end

%%% Flow rates, pump locations etc. for igeom = 8.
% set flowrate (m3/s) or ((m3/h)/3600)
qset   = 67/3600;  
nyrs   = 1;        % flow duration (yrs) - for user convenience

q_in = [];
q_out = [];


% Testbank options to check if the code was broken during recent update: 
if testbank == 0
    ntests = 1;
    alltests = igeom;
    disp (['mineheat: running + plotting geometry ',num2str(igeom),'.'])
    disp('-------')
elseif testbank == -1 || testbank == 1
    ntests = 10;
    igeomarray  = [1 2 3 4 5 6 7 101 102 103];
    disp (['mineheat: Testbank: testing geometries ',num2str(igeomarray),'.'])
    disp('-------')
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
paramsenstest = 0;

switch paramsenstest
    case 0 % Single time run, allows
        nyrs_array = nyrs; % alows for generality of code in runSummary.m between single and multi year cases
        %ntests = 1;
        
    case 1 % duration
        nyrs_array = [0.125 0.25 0.5 1 2 4 8 16 32 64 128 256 512 1024 2048 4096 9192];
        nyrs_array = 2.^[-10:30];
        ntests = length(nyrs_array);
        nyrs_result = zeros(1,ntests);
        
        figureFlag = 0;     % Do not print maps on multi time run
        savePrompt = 0;     % Do not use UIsave option
        
    case 2 % automatically assess different input and output locations
        %%%% Place holder
        
    case 3 % Multiple properties input - allows for random_input_mod.m to be used at a later date
        %%%% Place holderu
        
end




if testbank ~= 0 && paramsenstest ~=0
    error('Error, cannot use testbank and paramsenstest simultaneously')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% MINEGEOTHERMAL MODEL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for irun = 1:ntests  
    if testbank == -1 || testbank == 1
        igeom = igeomarray(irun);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if paramsenstest > 0  % set up series of parameter sensitivity tests.
        
        if paramsenstest == 1           %%% Modify nyrs for 'time-series' analysis     
            nyrs = nyrs_array(irun);    
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Read in geometries and return arrays required by mineflow
    disp('Running: geometries.m - generating problem geometry')
    [nn, no, np, A12, A10, xo, x, Ho, q, idiagn] = geometries(igeom,qset,q_in,q_out,testbank);
    disp('Call complete: geometry generation sucessful, flow model variable initialised')
    disp('-------')
     
    % Calculate pipe lengths, initialise pipe diameters as a vector
    [pipe_nodes, xtotal, L, d] = mine_array_setup('1', np, A12, A10, xo, x, d_set);
       

    % Calculate flow through pipe system:
    disp('Running: mineflow.m - calculating hydraulic heads and pipe flow volumes')
    [H Q]  = mineflow(nn, no, np, x, xo, A12, A10, Ho, q, L, d);
    disp('Call complete: geometry generation sucessful, flow model variable initialised')
    disp('-------')

    
    

    %%% Setup pipe flow arrays:
    [pipe_nodes npipes node_pipes_out node_pipes_in Q, v, n_tree, id_tree] ...
           = mine_array_setup('2', np, nn, no, A10, A12, pipe_nodes, q, Q, d);

    %%% Calculate temperature of pipe system:
    % Initial rock temperature (in degC):   
    Tin    = Tf_ini*ones(np,1);    %%% Is this correct - you are using water temperature?
    disp('Running: mine_heat.m - calculating nodal and pipe temperatures')

    %   Current script for mine_heat - contains fixes for known bugs
    [Tn Tp rp]= mine_heat(nyrs, d, L, Q, v, np, nn, no, Tf_ini, k_r, Cp_r, rho_r,...
        Tr, npipes, node_pipes_in, node_pipes_out, pipe_nodes,xtotal,PhysicalProperties,testbank,x,xo, n_tree, id_tree);

    disp('Call complete: thermal calculation sucessful')
    disp('-------')


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
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% POST-PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% FIGURES
switch figureFlag
    case 0     %%% Only gnerate summary data
        
        disp('Output: figureFlag = 0, no figures generated')
        summaryTable = runSummary(paramsenstest,nyrs_array,x,xo,q,Tn);
        disp(summaryTable)
        
        if savePrompt == 1
            AskUser = questdlg('Do you want to save output summary?','Save outputs',{'Save As','No'});
            waitfor(AskUser)
            
            switch AskUser
                case 'Yes'
                    writetable(summaryTable,'OutputTemps.xlsx');
                case 'No'
                    disp('User selection: Do not save outputs')
            end
        end
        
    case 1  %%% Generate maps
        
        % plot results:
        if testbank == 0 && paramsenstest == 0 % only plot results when not performing testbank tasks:
            %     disp('Plotting... Please wait');
            disp('Running: mineplots.m - plotting outputs')
            tic
            mine_plots (igeom, xo, x, d, np, nn, pipe_nodes, Tp, Tn, Q, H, Ho, Tr, Tf_ini, q, inferno, rp)
            toc
        end
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