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
function [nn, no, np, A12, A10, xo, x] = geometry101;

% 20210609 Modification from geometry1: 
%          only one fixed head node (at outflow)
%          and instead imposing q at inflow node

% Linear pipe system:
%      * - o - o - o - ... - o - * 
% in = 1   2   3            nn        nn = nr of unknown heads
% io =                           1    no = nr of known heads
% ip =   1   2   3   4   np-1 np      np = nr of pipes

% size of problem:
nn  = 10;      % nr of unknown head nodes
no  = 1;       % nr of fixed head nodes
np  = 10;      % nr of pipes
total_length = 1000;  %total gallery length in m

% Parameters to be solved in this function:

A12 = sparse(np,nn);
A10 = sparse(np,no);
A11inv = sparse(np,np);
xo  = zeros(no,2);
x   = zeros(nn,2);

% locations of nodes:
segment_length = total_length/np;   % e.g. 10 for 1km pipe
xo(1,:) = [np*segment_length 0];
x(:,1)=linspace(0, (nn-1)*segment_length, nn)';

% General definition of matrix A12 (and A10): 
%    A12(ip,in) = if    
%    means: if if==1, then pipe ip feeds into node in
%           if if==-2, then pipe ip flows out of node in
% In linear pipe configuration, for each node in, pipe in feeds into 
% node in, and pipe in+1 leaves node in:
for in=1:nn-1
    ip=in;
    A12(ip,in+1) = 1;
    A12(ip,in) = -1;
end
A12(np,nn) = -1;

% last node (the ony fixed-head node) has last pipe as incoming pipe:
A10(np,1) = 1;

% Pipe length: should be calculated from x, A12, and A10 instead of set here:
%xtotal = [x; xo(1,:)];
%L      = diff(xtotal, 1,1);

% % pipe diameters: set in mine_geothermal
% d   = 2*ones(np,1);
% %d(2,1) = 0.05;