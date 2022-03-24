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

function [T_st] = source_terms(case_st,varargin)
   % Assiging the source terms for the model
   %    currently only the temperature is assigned here
   %    the flow st q is still assigned in geometries
   % 
    switch case_st 
        % Injection point set to Tf_ini, everything else to Tr
        case 1
            [q_in, q_out, Tr, Tf_ini, no, nn, Ho] = varargin{1:end};

            % Inflow temperature for all the nodes
            T_st = zeros(no+nn,1) + Tr;
            % for injection node override with Tf_ini
            for i = 1:length(q_in)
                T_st(q_in{i} + no) = Tf_ini;
            end
        
        % If head defined model Tf_ini is applied to the highest fixed
        % pressure node.
        case 2
            [q_in, q_out, Tr, Tf_ini, no, nn, Ho] = varargin{1:end};
            % Inflow temperature for all the nodes
            T_st = zeros(no+nn,1) + Tr;
            % for max pressure node override with Tf_ini
            maxHi = find(Ho == max(Ho)); % index of max pressure node
            T_st(maxHi) = Tf_ini;

        otherwise
            % default ST
            [q_in, q_out, Tr, Tf_ini, no, nn, Ho] = varargin{1:end};

            % Inflow temperature for all the nodes
            T_st = zeros(no+nn,1) + Tr;
    end
end