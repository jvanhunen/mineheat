function [kr_in, Cp_in, rho_in, diameter_in, Tr_in] = random_input_mod()

% See shared Google Sheets "Model variables" for justification of values

%----------------------------------------------------------------------
% pipeheat.m

% Rock heat conductivity (W/m,K)
kr_min = 3; % e.g. 2.3
kr_max = 3; % e.g. 3.9
kr_diff = kr_max - kr_min;

% Rock specific heat
Cp_min = 900; % e.g. 740
Cp_max = 900; % e.g. 920
Cp_diff = Cp_max - Cp_min;

% Rock density
rho_min = 2300; % e.g. 2100
rho_max = 2300; % e.g. 2700 
rho_diff = rho_max - rho_min;

%----------------------------------------------------------------------
% Geometry file

% Diameter of tunnels
diameter_min = 3.6; % e.g. 1.7
diameter_max = 3.6; % e.g. 2.7
diameter_diff = diameter_max - diameter_min;

%---------------------------------------------------------------------
% mine_geothermal.m

% Initial rock temperature
Tr_min = 25; % e.g. 14.5
Tr_max = 25; % e.g. 15.5
Tr_diff = Tr_max - Tr_min;


kr_in = (rand(1,1) * kr_diff) + kr_min;
Cp_in = (rand(1,1) * Cp_diff) + Cp_min;
rho_in = (rand(1,1) * rho_diff) + rho_min;
diameter_in = (rand(1,1) * diameter_diff) + diameter_min;
Tr_in = (rand(1,1) * Tr_diff) + Tr_min;

end