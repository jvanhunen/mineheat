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
function [nn, no, np, A12, A10, xo, x] = hawthorn_model(igeom,option)

clear geom

if option == 1
    if igeom == 1
        geom = xlsread('data/mine_system.xlsx','high main');
    elseif igeom == 2
        geom = xlsread('data/mine_system.xlsx','low main');
    elseif igeom == 3
        geom = xlsread('data/mine_system.xlsx','harvey');
    end
elseif option == 2
    if igeom == 1
        geom = xlsread('data/mine_system_alt.xlsx','high main');
    elseif igeom == 2
        geom = xlsread('data/mine_system_alt.xlsx','low main');
    elseif igeom == 3
        geom = xlsread('data/mine_system_alt.xlsx','harvey');
    end
end
    

% size of problem:
nn  = max(geom(:,1));      % nr of unknown head nodes
no  = 2;                   % nr of fixed head nodes
np  = max(geom(:,4));      % nr of pipes

% Parameters to be solved in this function:

A12 = sparse(np,nn);
A10 = sparse(np,no);
A11inv = sparse(np,np);
xo  = zeros(no,2);
x   = zeros(nn,2);

% locations of nodes: 
xo = geom(1:2,2:3);
x = sparse(geom(3:end,2:3));

A10 = sparse(geom(:,5:6));
A12 = sparse(geom(:,7:end)); %*-1?

end

% % pipe diameters: set in mine_geothermal
% d   = d_in*ones(np,1);
% % Likely 2.3 +/- 0.4 m
% % See notes 22nd Jan for justification