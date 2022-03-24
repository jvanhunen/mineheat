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

function [nn, no, np, A12, A10, xo, x] = geometry3

% in =         2   3   4      
%              o - o - o 
% ip =     1 2/  3   4  \5  6 
% io = 1 * - o1          5o - * io=2  no = 2
% ip =       7\  8   9  /10           np = 8
%              o - o - o      
% in =         6   7   8              nn = 8
% 
% with: 
%   - = pipe
%   o = unknown head node
%   * = fixed head node
% 
% size of problem:
nn  = 8;      % nr of unknown head nodes
no  = 2;       % nr of fixed head nodes
np  = 10;      % nr of pipes

% Parameters to be solved in this function:

A12 = zeros(np,nn);
A10 = zeros(np,no);
A11inv = sparse(np,np);
xo  = zeros(no,2);
x   = zeros(nn,2);

% locations of nodes: 
xo(1,:) = [  0 100];
xo(2,:) = [600 100];

x(1,:) = [100 100];
x(2,:) = [200   0];
x(3,:) = [300   0];
x(4,:) = [400   0];
x(5,:) = [500 100];
x(6,:) = [200 200];
x(7,:) = [300 200];
x(8,:) = [400 200];

% In linear pipe configuration, for each node in, pipe in feeds into 
% node in, and pipe in+1 leaves node in:
A10( 1, 1) = -1; A12( 1, 1) = 1; 
A12( 2, 1) = -1; A12( 2, 2) = 1; 
A12( 3, 2) = -1; A12( 3, 3) = 1; 
A12( 4, 3) = -1; A12( 4, 4) = 1; 
A12( 5, 4) = -1; A12( 5, 5) = 1;
A12( 6, 5) = -1; A10( 6, 2) = 1;
A12( 7, 1) = -1; A12( 7, 6) = 1;
A12( 8, 6) = -1; A12( 8, 7) = 1;
A12( 9, 7) = -1; A12( 9, 8) = 1;
A12(10, 8) = -1; A12(10, 5) = 1;

% % pipe diameters: set in mine_geothermal
% d   = 4*ones(np,1);
% d(2,1) = 2;