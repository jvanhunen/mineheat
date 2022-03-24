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
function [q_in, q_out] = testFlows(n_flows)

      % Initialise flow locations
        q_in  = cell(n_flows,1);
        q_out = cell(n_flows,1);
                
        % Select node locations based on previous input      
        switch n_flows
            case 1
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
            case 5
                q_in{1} = 50;
                q_out{1} = 1500;
            case 6
                q_in{1} = 6000;
                q_out{1} = 5;
        end

end
