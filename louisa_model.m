function [nn, no, np, A12, A10, xo, x] = louisa_model();

clear geom
geom = xlsread('data/LMM_2a-D');


% size of problem:
nn  = max(geom(:,1));      % nr of unknown head nodes
no  = 2;                   % nr of fixed head nodes
np  = max(geom(:,4));      % nr of pipes

% Parameters to be solved in this function:

A12 = sparse(np,nn);
A10 = sparse(np,no);
A11inv = sparse(np,np);
xo  = zeros(no,2);
x   = zeros(nn,2);

% locations of nodes: 
xo = geom(1:2,2:3);
x = geom(3:end,2:3);

A10 = geom(:,5:6);

A12 = geom(:,7:end);

% % pipe diameters: set in mine_geothermal
% d   = d_in*ones(np,1);
% % Likely 2.3 +/- 0.4 m
% % See notes 22nd Jan for justification