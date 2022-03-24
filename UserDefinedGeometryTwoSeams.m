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
function [nn, no, np, A12, A10, xo, x, Ho, q, idiagn] = UserDefinedGeometryTwoSeams(head)
printout = cell(10,1);
%%% Ask user to select shapefile, return path and filename for user
%%% selection
seamFilePaths = cell(2,1);  %%% Two seams
seamFile = cell(2,1);

AskUser = msgbox('Select shapefile for seam 1 (.shp)');
waitfor(AskUser);
[UserFile_seamOne, path_seamOne] = uigetfile('*.shp');
printout{1} = ['Seam 1: ' UserFile_seamOne];
disp(['User selection: ' printout{1} ' (seam 1)'])
seamFilePaths{1} = fullfile(path_seamOne,UserFile_seamOne);
seamFile{1} = UserFile_seamOne;


AskUser = msgbox('Select shapefile for seam 2 (.shp)');
waitfor(AskUser);
[UserFile_seamTwo, path_seamTwo] = uigetfile('*.shp');
printout{1} = ['Seam 2: ' UserFile_seamTwo];
disp(['User selection: ' printout{1} ' (seam 2)'])
seamFilePaths{2} = fullfile(path_seamTwo,UserFile_seamTwo);
seamFile{2} = UserFile_seamTwo;

if convertCharsToStrings(seamFile{1}) == convertCharsToStrings(seamFile{2})
   error('Error')
   %%% TODO insert while loop to hold code until user selects a different
   %%% file for seam 2
end


%%% Run UserArcGeometry on UserFile, initialise variables for
%%% mineflow
[nn, no, np, A12, A10, xo, x] = UserArcGeometrySecondSeamZ(seamFilePaths);


%%% Specify number of nodes to be assigned inflow and outflow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AskUser = msgbox('Specify number of inflow and outflow points');
waitfor(AskUser);
n_flows_inout = inputdlg({'Specify number of inflow nodes','Specify number of outflow nodes'});
n_flows_in = str2num(n_flows_inout{1});
n_flows_out = str2num(n_flows_inout{2});
printout{2} = ['Number of user specified inflow points = ' num2str(n_flows_in)];
printout{3} = ['Number of user specified outflow points = ' num2str(n_flows_out)];
disp(['User selection: ' printout{2}]);
disp(['User selection: ' printout{3}]);

%%% Ask user to specify node numbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AskUser = msgbox(['Specify inflow and outflow nodes - Total free nodes in model = ' num2str(nn)]);
waitfor(AskUser);
q_inout = inputdlg({'Set inflow node(s)','Set outflow node(s)'});
q_in = str2num(q_inout{1});  % inflow  nodes
q_out = str2num(q_inout{2}); % outflow nodes

%%% Check nodes fall in range
if (max(q_in) || max(q_out)) > nn
    warning(['Specified node exceeds total nodes in model (Total free nodes = ' num2str(nn) ')'])
    
        %%%% Loop over re-specification untill user gets it right
        while 1
        AskUser = msgbox(['Re-specify inflow and outflow nodes - Node numbers cannot exceed ' num2str(nn)]);
        waitfor(AskUser);
        q_inout = inputdlg({'Set inflow node(s)','Set outflow node(s)'});
        q_in = str2num(q_inout{1});  % inflow  nodes
        q_out = str2num(q_inout{2}); % outflow nodes
        if (max(q_in) || max(q_out)) <= nn
            break
        end
        end
end

%%% If too many nodes specify, ignore additional points
if (numel(q_in)> n_flows_in || numel(q_out) > n_flows_out)
    q_in = q_in(1:n_flows_in);
    q_out = q_out(1:n_flows_in);
    warning('Number of specified in- and/or outflow node locations exceeds number of specified nodes. Model will proceed using ignoring additional flow locations')
    
    %%% TODO update code to give user options of
    % 1 - udate number of nodes to include additional
    % 2 - ignore additional and proceed with pre-selected
    
end

%%% If too few nodes specified, ask for user to redo input
if (numel(q_in)< n_flows_in || numel(q_out) < n_flows_out)
    warning('Number of specified in- and/or outflow node locations is less than number of specified nodes. Please provide additional node locations')
    
    %%% Holds code in an indefinite loop until user specifies number of
    %%% nodes that matches 
    while 1
    AskUser = msgbox(['Re-specify inflow and outflow nodes - Total free nodes in model = ' num2str(nn)]);
    waitfor(AskUser);
    q_inout = inputdlg({'Set inflow node(s)','Set outflow node(s)'});
    q_in = str2num(q_inout{1});  % inflow  nodes
    q_out = str2num(q_inout{2}); % outflow nodes
    
    if (numel(q_in)>= n_flows_in || numel(q_out) >= n_flows_out)
       break      
    end
    end
end

printout{4} = ['Inflow node IDs - [' num2str(q_in) ']'];
printout{5} = ['Outflow node IDs - [' num2str(q_out) ']'];
disp(['User selection: ' printout{4}])
disp(['User selection: ' printout{5}])


%%% Ask user to set in/outflow rate
AskUser = msgbox('Specify inflow and outflow flowrates [m$^3$ /s]','interpreter','tex');
waitfor(AskUser)
qset = inputdlg({'Set inflow flowrate(s)','Set outflow flowrate(s)'});
qin  = abs(str2num(qset{1}));
qout = abs(str2num(qset{2}));

%%% If all wells are to be assigned same flow rates, user only
%%% needs to specify this once, padd out qin and/or with
%%% duplicate values
if (numel(qin) == 1 & n_flows_in ~=1)
    qin = zeros(1,n_flows_in)+qin(1);
end

if (numel(qout) == 1 & n_flows_out ~=1)
    qout = zeros(1,n_flows_out)+qout(1);
end

printout{6} = ['Specified inflow rates (m^3/s) - [' num2str(qin) ']'];
printout{7} = ['Specified inflow rates (m^3/s) - [' num2str(qout) ']'];
disp(['User selection: ' printout{6}])
disp(['User selection: ' printout{7}])
%%% Check for a significant difference between total inflow and
%%% total outflow - 0.1
if abs(sum(qin)-sum(qout)) > 0.1
    error('Total inflow and outflow rates must balance. Reselect')
end


%%% Set external in/outflow at each non-fixed head node:
q = zeros(nn,1);
%%% Inflow nodes
for i = 1:n_flows_in
    q(q_in(i)) = -qin(i);
end

%%% Outflow nodes
for i = 1:n_flows_out
    q(q_out(i)) = qout(i);
end

%%% Set fixed hydraulic heads:
Ho     = zeros(no,1);
Ho(1)  = head;

idiagn = nn;

end