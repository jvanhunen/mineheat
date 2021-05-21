function [nn, no, np, A12, A10, xo, x, d] = geometrytest;

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
np  = 9;      % nr of pipes

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




A12(9,1) = 1;
A12(9,5) = -1;

% 
% A12 =   [1, 0, 0, 0, 0, 0;...
%         -1, 1, 0, 0, 0, 0;...
%         -1, 0, 0, 0, 1, 0;...
%          0,-1, 1, 0, 0, 0;...
%          0, 0,-1, 0, 0, 0;...
%          0, 0, 0, 1, 0, 0;...
%          0, 0, 0,-1, 1, 0;...
%          0, 0, 0, 0,-1, 1;...
%          0, 0, 0, 0, 0,-1];




% first fixed-head node has outgoing pipes (i.e. defined as at beginning of
% pipe)
A10(1,1) = -1;
A10(5,1) = -1;
% last fixed-head node has incoming pipes (i.e. defined as at end of pipe)
A10(4,2) = 1;
A10(8,2) = 1;

% pipe diameters: 
d   = 4*ones(np,1);
d(2,1) = 2;