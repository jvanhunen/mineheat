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

function [nn, no, np, A12, A10, xo, x] = geometry2;

% in =     1   2   3      
%          o - o - o 
% ip =  1 /  2   3  \ 4 
% io = 1 *           * io=2   no = 2
% ip =  5 \  6   7  / 8       np = 8
%          o - o - o      
% in =     4   5   6          nn = 6
% 
% with: 
%   - = pipe
%   o = unknown head node
%   * = fixed head node
% 
% size of problem:
nn  = 6;      % nr of unknown head nodes
no  = 2;       % nr of fixed head nodes
np  = 8;      % nr of pipes

% Parameters to be solved in this function:

A12 = sparse(np,nn);
A10 = sparse(np,no);
A11inv = sparse(np,np);
xo  = zeros(no,2);
x   = zeros(nn,2);

% locations of nodes: 
xo(1,:) = [  0 100];
xo(2,:) = [400 100];
x(1,:)  = [100   0];
x(2,:)  = [200   0];
x(3,:)  = [300   0];
x(4,:)  = [100 200];
x(5,:)  = [200 200];
x(6,:)  = [300 200];

% General definition of matrix A12 (and A10): 
%    A12(ip,in) = if    
%    means: if if==1, then pipe ip feeds into node in
%           if if==-2, then pipe ip flows out of node in == -1?
% In linear pipe configuration, for each node in, pipe in feeds into 
% node in, and pipe in+1 leaves node in:
for in=1:3
    A12(in,in) = 1;
    A12(in+1,in) = -1;
end
for in=4:6
    A12(in+1,in) = 1;
    A12(in+2,in) = -1;
end

% first fixed-head node has outgoing pipes (i.e. defined as at beginning of
% pipe)
A10(1,1) = -1;
A10(5,1) = -1;
% last fixed-head node has incoming pipes (i.e. defined as at end of pipe)
A10(4,2) = 1;
A10(8,2) = 1;

% % pipe diameters: set in mine_geothermal
% d   = 4*ones(np,1);
% d(2,1) = 2;