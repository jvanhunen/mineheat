function [nn, no, np, A12, A10, xo, x, d] = hawthorn_model(d_in,igeom,option)

clear geom

if option == 1
    if igeom == 1
        geom = xlsread('data/mine_system.xlsx','high main');
    elseif igeom == 2
        geom = xlsread('data/mine_system.xlsx','low main');
    elseif igeom == 3
        geom = xlsread('data/mine_system.xlsx','harvey');
    end
elseif option == 2
    if igeom == 1
        geom = xlsread('data/mine_system_alt.xlsx','high main');
    elseif igeom == 2
        geom = xlsread('data/mine_system_alt.xlsx','low main');
    elseif igeom == 3
        geom = xlsread('data/mine_system_alt.xlsx','harvey');
    end
end
    

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

A12 = geom(:,7:end); %*-1?

% pipe diameters: 
d   = d_in*ones(np,1);
% Likely 2.3 +/- 0.4 m
% See notes 22nd Jan for justification