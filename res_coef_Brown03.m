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
function r = res_coef_Brown03(Q,L,d)
   % Calculating resistance coeff of a pipe, using the Darcy-Weisbach
   % formulation as described in Brown, 2003:
   %    r=f*8/(pi^2*g)*L/d^5
   %            f    = the friction factor (p.189 of EPAnet manual)
   %            d    = diameter of the pipe (m)
   %            L    = length of the pipe (m)
   %            g    = gravitational acceleration 
   % 
   % Note that this calculation is based on values/formulae for pipes
   % Not sure how valid this is for mine galleries
   % 
   eps = 0.1;  % Darcy-Weisbach roughness coeff (e.g. 0.001)
               % Values listed in EPANET manual Table 3.2, p.31 (in 1e-3 ft!)
               % On
               % https://en.wikipedia.org/wiki/Darcy%E2%80%93Weisbach_equation,
               %    this roughness is compared to the diameter D, and has
               %    the same units (i.e. metres). So perhaps eps=0.01 is
               %    too small for the mine roadway walls?
   rho = 1000;  % density of water (kg/m3)
   mu  = 1e-3;  % dynamic viscosity of water (Pa s)
   % Reynolds number = rho*v*d/mu, with v=Q/(pi*r^2) = 4*Q/(pi*d^2)
   %    (for flow in pipe, see https://en.wikipedia.org/wiki/Reynolds_number)
   Re  = rho*abs(4*Q/(pi*d^2))*d/mu;
   f = pipe_friction_factor(Re, d, eps);
   g = 9.8;
   r = f*8/(pi^2*g)*L/d^5;
end