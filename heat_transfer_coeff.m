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
function h = heat_transfer_coeff (k, r, v, nu, rho, Cp)
% Calculates the effective heat transfer coefficient
% Equation taken from Rodriguez & Diaz, 2009, Eqn 1
% This is based on the Dittus-Boelter eqn
% 
% k = thermal conductivity
% r = pipe radius
% v = fluid flow velocity
% nu = kinematic viscosity
% rho = fluid density
% Cp = fluid heat capacity

coef1 = (2*v*r/nu)^0.8;
coef2 = (rho*Cp*nu/k)^0.43;
h = k/(2*r)*0.021*coef1*coef2;
