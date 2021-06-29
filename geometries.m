function [nn, no, np, A12, A10, xo, x, d, Ho, q] = geometries(igeom)
% Set mine geometry, fixed hydraulic heads, and external flow constraints:
%  - geometry (node locations & pipe connections) in function geometryX
%  - fixed hydraulic heads of all nodes xo
%  - external in/outflow for all nodes x 

head   = 1e-11;     % hydraulic head loss through mine (m). e.g. 6.3e-12 

if igeom==1
    % linear pipesystem:
    [nn, no, np, A12, A10, xo, x, d] = geometry1();
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = head;  % ... and by definition, Ho(2)=0;
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
elseif igeom==2
    % dual, parallel pipesystem:
    [nn, no, np, A12, A10, xo, x, d] = geometry2();
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = head;  % ... and by definition, Ho(2)=0;
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
elseif igeom==3
    % partly dual, parallel pipesystem:
    [nn, no, np, A12, A10, xo, x, d] = geometry3();
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = head;  % ... and by definition, Ho(2)=0;
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
elseif igeom==4
    % small grid:
    [nn, no, np, A12, A10, xo, x, d] = geometry4();
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = head;  % ... and by definition, Ho(2)=0;
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
elseif igeom==5
    % large grid (diss Marijn Huis):
    n  = 31;   % grid width (number of nodes wide)
    m  = 11;   % grid height (number of nodes high)
    l1 = 100;  % length of horizontal pipes
    l2 = 100;  % length of vertical pipes
    [nn, no, np, A12, A10, xo, x, d] = geometry_grid(n , m, l1, l2);
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = head;  % ... and by definition, Ho(2)=0;
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
elseif igeom==6
    % Louisa model (ESII 19/20): 
    diam = 4.0;
    [nn, no, np, A12, A10, xo, x, d] = louisa_model(diam);
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = head;  % ... and by definition, Ho(2)=0;
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
elseif igeom==7
    % Hawthorn model (ESII 20/21): 
    igeomH = 1;
    optionH = 1;
    diam = 4.0;
    [nn, no, np, A12, A10, xo, x, d] = hawthorn_model(diam,igeomH,optionH);
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = head;  % ... and by definition, Ho(2)=0;
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
elseif igeom==101
    % linear pipesystem with one fixed head, and one prescribed inflow point:
    [nn, no, np, A12, A10, xo, x, d] = geometry101();
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = 0; % only-fixed-head node is extraction node.
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
    q(1) = -1.575e-4;  % prescribed external flow into first node 
elseif igeom==102
    % linear pipesystem with one fixed head, and two prescribed in/outflow points:
    [nn, no, np, A12, A10, xo, x, d] = geometry102();
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = 5e-12; % only-fixed-head node is in middle.
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
    q(2) = -1.575e-4;  % prescribed external flow into first node 
    q(nn-1) = 1.575e-4;  % prescribed external flow out of last node 
end