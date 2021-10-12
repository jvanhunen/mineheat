function [nn, no, np, A12, A10, xo, x, Ho, q, idiagn] = geometries(igeom,qset,q_in,q_out)
% Set mine geometry, fixed hydraulic heads, and external flow constraints:
%  - geometry (node locations & pipe connections) in function geometryX
%  - fixed hydraulic heads of all nodes xo
%  - external in/outflow for all nodes x 

% version 20210720 JvH:
%    added idiagn option to output parameters

head   = 1e-7;     % hydraulic head loss through mine (m). e.g. 6.3e-12 

if igeom==1
    % linear pipesystem:
    [nn, no, np, A12, A10, xo, x] = geometry1();
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = head;  % ... and by definition, Ho(2)=0;
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
    idiagn = nn;
elseif igeom==2
    % dual, parallel pipesystem:
    [nn, no, np, A12, A10, xo, x] = geometry2();
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = head;  % ... and by definition, Ho(2)=0;
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
    idiagn = nn;
elseif igeom==3
    % partly dual, parallel pipesystem:
    [nn, no, np, A12, A10, xo, x] = geometry3();
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = head;  % ... and by definition, Ho(2)=0;
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
    idiagn = nn;
elseif igeom==4
    % small grid:
    [nn, no, np, A12, A10, xo, x] = geometry4();
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = head;  % ... and by definition, Ho(2)=0;
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
    idiagn = nn;
elseif igeom==5
    % large grid (diss Marijn Huis):
    n  = 31;   % grid width (number of nodes wide)
    m  = 11;   % grid height (number of nodes high)
    l1 = 100;  % length of horizontal pipes
    l2 = 100;  % length of vertical pipes
    [nn, no, np, A12, A10, xo, x] = geometry_grid(n , m, l1, l2);
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = head;  % ... and by definition, Ho(2)=0;
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
    idiagn = nn;
elseif igeom==6
    % Louisa model (ESII 19/20): 
    % diam = 4.0; set in mine_geothermal
    [nn, no, np, A12, A10, xo, x] = louisa_model();
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = head;  % ... and by definition, Ho(2)=0;
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
    idiagn = nn;
elseif igeom==7
    % Hawthorn model (ESII 20/21): 
    igeomH = 1; % 1=high main 2=low main 3=harvey
    optionH = 1;
    % diam = 3.0; set in mine_geothermal
    [nn, no, np, A12, A10, xo, x] = hawthorn_model(igeomH,optionH);
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = head;  % ... and by definition, Ho(2)=0;
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
    idiagn = nn;
elseif igeom==8
    %ArcGIS Shapefile Geometry
    [nn, no, np, A12, A10, xo, x] = ArcGeometry();
    % Check if in/outflow locations fit in nodal space
    if max([q_in{:}]) > nn || max([q_out{:}]) > nn
        error('q_in and/or q_out locations are greater than nodal space of mine model. Choose different q_in and/or q_out.');
    end
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = 0;
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
    for i = 1:length(q_in)
        q(q_in{i})  = -qset;
        q(q_out{i}) = qset;
    end
    idiagn = nn;
elseif igeom==101
    % linear pipesystem with one fixed head, and one prescribed inflow point:
    [nn, no, np, A12, A10, xo, x] = geometry101();
    % Check if in/outflow locations fit in nodal space
    if max([q_in{:}]) > nn || max([q_out{:}]) > nn
        error('q_in and/or q_out locations are greater than nodal space of mine model. Choose different q_in and/or q_out.');
    end
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = 0; % only-fixed-head node is extraction node.
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
    for i = 1:length(q_in)
        q(q_in{i})  = -qset;
        q(q_out{i}) = qset;
    end
    idiagn = nn;
elseif igeom==102
    % linear pipesystem with one fixed head, and two prescribed in/outflow points:
    [nn, no, np, A12, A10, xo, x] = geometry102();
    % Check if in/outflow locations fit in nodal space
    if max([q_in{:}]) > nn || max([q_out{:}]) > nn
        error('q_in and/or q_out locations are greater than nodal space of mine model. Choose different q_in and/or q_out.');
    end
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    %Ho(1)  = 5e-12; % only-fixed-head node is in middle.
    Ho(1) = 0;
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
    for i = 1:length(q_in)
        q(q_in{i})  = -qset;
        q(q_out{i}) = qset;
    end
    idiagn = nn+no;
elseif igeom==103
    % large grid (diss Marijn Huis):
    n  = 10;   % grid width (number of nodes wide)
    m  = 15;   % grid height (number of nodes high)
    l1 = 100;  % length of horizontal pipes
    l2 = 100;  % length of vertical pipes
    [nn, no, np, A12, A10, xo, x] = geometry103(n , m, l1, l2);
    % Check if in/outflow locations fit in nodal space
    if max([q_in{:}]) > nn || max([q_out{:}]) > nn
        error('q_in and/or q_out locations are greater than nodal space (nn) of mine model. Choose different q_in and/or q_out.');
    end
    % set fixed hydraulic heads:
    Ho     = zeros(no,1);
    Ho(1)  = 0;
    % set any external in/outflow for each (non-fixed) node:
    q    = zeros(nn,1);
    for i = 1:length(q_in)
        q(q_in{i})  = -qset;
        q(q_out{i}) = qset;
    end
    idiagn = 148;  % not very useful, since there are 2 outlets, not 1.
end