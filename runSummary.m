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
function summaryTable = runSummary(paramsenstest,nyrs_array,x,xo,q,T)

Nout = sum(q>0);      %%% Total outflow points
indOut = find(q>0);   %%% Get index of outflow points
x = [xo;x];           %%% Coordinates of nodes


switch paramsenstest
    
    case 0      %%%% Basic model run
        
        %%%% Initialise results table
        summaryTable = cell(Nout, 2+size(x,2)+2);   
        
        %%% Table structure: 1 row for each of the Nout outflow points
        %%% Col 1 = Outflow node num.  Col 2 = Flow rate at outflow node
        %%% Col 3,4 (and 5 for multi seam) = x,y,z ordinates of flow point
        %%% Col 5 (or 6 for 3D) = Temperature
        %%% Col 6 (or 7 for 3D) = nyrs
        
        for i = 1:Nout
            summaryTable{i,1} = indOut(i);
            summaryTable{i,2} = q(indOut(i));
            summaryTable{i,3} = x(i,1);
            summaryTable{i,4} = x(i,2);
            
            
            if size(x,2) == 2
                summaryTable{i,5} = T(indOut(i));
                summaryTable{i,6} = nyrs_array;
            elseif size(x,2) == 3
                summaryTable{i,5} = x(i,3);
                summaryTable{i,6} = T(indOut(i));
                summaryTable{i,7} = nyrs_array;
            end
        end
        
        if size(x,2) == 2
            varNames = {'Outflow_Node_ID','Outflow_Rate','x','y','T_out','runTime_nyrs'};
        elseif size(x,2) == 3
            varNames = {'Outflow_Node_ID','Outflow_Rate','x','y','z','T_out','runTime_nyrs'};
        end
        
        summaryTable = cell2table(summaryTable,'VariableNames',varNames);
        
        
        
    case 1
        summaryTable = cell(Nout*numel(nyrs_array), 2+size(x,2)+2);   
        
        for i = 1:Nout
 
            
            
        end
        
end


end
