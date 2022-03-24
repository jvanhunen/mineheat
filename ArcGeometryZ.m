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

function [nn, no, np, A12, A10, xo, x] = ArcGeometryZ

S = shaperead('maps/BustyZ.shp');
sizeofS = size(S);
npoints = sizeofS(1);
flow_dir = zeros(npoints,1);
for ipoint = 1:npoints
    if (S(ipoint).POINT_X == S(ipoint).EXT_MIN_X && S(ipoint).POINT_Y == S(ipoint).EXT_MIN_Y)
       flow_dir(ipoint) = -1; 
    end
    if (S(ipoint).POINT_X == S(ipoint).EXT_MAX_X && S(ipoint).POINT_Y == S(ipoint).EXT_MAX_Y)
       flow_dir(ipoint) = 1;   
    end
end
max_node_id = 0;
for ipoint = 1:npoints
    if S(ipoint).NODEID > max_node_id
        max_node_id = S(ipoint).NODEID;
    end
end

ntemp = max_node_id;

max_pipe_id = 0;
for ipoint = 1:npoints
    if S(ipoint).PIPEID > max_pipe_id
        max_pipe_id = S(ipoint).PIPEID;
    end
end
np = max_pipe_id;

% size of problem:
no  = 1;       % nr of fixed head nodes

% Parameters to be solved in this function:

Atemp = zeros(np,ntemp);
%A11inv = zeros(np,np);
xtemp   = zeros(ntemp,3);

% locations of nodes

for ipoint = 1:npoints
    nodeid = S(ipoint).NODEID;
    xtemp(nodeid,:) = [S(ipoint).POINT_X,S(ipoint).POINT_Y,S(ipoint).POINT_Z];
end

% In linear pipe configuration, for each node in, pipe in feeds into 
% node in, and pipe in+1 leaves node in:

for ipoint = 1:npoints
    nodeid = S(ipoint).NODEID;
    pipeid = S(ipoint).PIPEID;
    Atemp(pipeid,nodeid) = flow_dir(ipoint);
end

check1=find(sum(Atemp,2)~=0)
Atemp2 = abs(Atemp);
check2=min(sum(Atemp2,1))
check3=find(sum(Atemp2,2)~=2)
no=1;
nn = ntemp-1;
A10 = sparse(Atemp(:,1));
A12 = sparse(Atemp(:,2:end));
xo = xtemp(1,:);
x = xtemp(2:end,:);

% % pipe diameters: set in mine_geothermal
% d   = 4*ones(np,1); 
