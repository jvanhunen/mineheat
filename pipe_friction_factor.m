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

function f = pipe_friction_factor(Re, d, eps)
    % Version 20210729 JvH
    %    minor correction: Y2 = logfactor rather than Y2=log(logfactor)
    %        makes negligible difference
    %    Note that the use of log10 for Re>4000, while using log for
    %        2000<Re<4000 is correct 
    % Jeroen van Hunen, 20190505
    % This function calculates the friction factor for flow in a pipe.
    % From EPANET 2 manual (2000), App.D, p.189.
    % Arguments: 
    %  Re = Reynolds nr
    %  d = pipe diameter (m or ft)
    %  eps = Darcy-Weisbach roughness coefficient (m or ft)
    % Note that both d and eps can be in either m or ft, but the same unit
    %    must be used for both.
    
    %Re = max(Re, 100);  % avoid dividing by zero for zero flow

    if Re<2000
        % laminar regime:
        f=64/Re;
    elseif Re>4000
        % turbulent regime, Swamee–Jain equation (from Bhave, 1991):
        % Note that, unlike stated in EPANET manual, the log used in (only)
        %   this formula should be a log10, not an ln, hence the log(10)^2 
        %   to compensate for that. 
        lf = logfactor(Re, d, eps);
        f = 0.25 / log10(lf)^2; 
        %f = 0.25 / log(lf)^2; 
    else
        % intermediate regime (Dunlop. 1991):
        R  = Re/2000;
        Y2 = logfactor(Re, d, eps);
        Y3 = -0.86859*log(logfactor(4000, d, eps));
        FA = Y3^-2;
        FB = FA * (2-0.00514215/Y2/Y3);
        X1 = 7*FA - FB;
        X2 = 0.128 -17*FA + 2.5*FB;
        X3 = -0.128 +13*FA - 2*FB;
        X4 = R*(0.032 - 3*FA + 0.5*FB);
        f  = (X1+ R*(X2 + R*(X3 + X4)));
    end
    
end

function lf = logfactor(Re, d, eps)
   lf = eps/(3.7*d)+5.74/Re^0.9;
end
        