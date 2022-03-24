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