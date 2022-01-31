function [nn, no, np, A12, A10, xo, x] = geometry4

% in =         2 3  3   4      
%              o - o - o 
% ip =     1 2/ |   4  \5  6 
% io = 1 * - o1 |11      5o - * io=2  no = 2
% ip =       7\ |8   9  /10           np = 8
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
np  = 13;      % nr of pipes

% Parameters to be solved in this function:

A12 = zeros(np,nn);
A10 = zeros(np,no);
A11inv = sparse(np,np);
xo  = zeros(no,3);
x   = zeros(nn,3);

% locations of nodes: 
xo(1,:) = [  0 200 0];
xo(2,:) = [600   0 0];

x(1,:) = [100 200 0];
x(2,:) = [200   0 0];
x(3,:) = [300   0 0];
x(4,:) = [400   0 0];
x(5,:) = [500   0 0];
x(6,:) = [200 200 0];
x(7,:) = [300 200 0];
x(8,:) = [400 200 0];

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
A12(11, 2) = -1; A12(11, 6) = 1;
A12(12, 3) = -1; A12(12, 7) = 1;
A12(13, 4) = -1; A12(13, 8) = 1;

% % pipe diameters: set in mine_geothermal
% d   = 4*ones(np,1);
% %d(2,1) = 2;