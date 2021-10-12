function [nn, no, np, A12, A10, xo, x] = ArcGeometry

S = shaperead('G17P_SpatialJoin12.shp');
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
A11inv = zeros(np,np);
xtemp   = zeros(ntemp,2);

% locations of nodes

for ipoint = 1:npoints
    nodeid = S(ipoint).NODEID;
    xtemp(nodeid,:) = [S(ipoint).POINT_X,S(ipoint).POINT_Y];
end

% In linear pipe configuration, for each node in, pipe in feeds into 
% node in, and pipe in+1 leaves node in:

for ipoint = 1:npoints
    nodeid = S(ipoint).NODEID;
    pipeid = S(ipoint).PIPEID;
    Atemp(pipeid,nodeid) = flow_dir(ipoint);
end

Atemp;
Atemp2 = abs(Atemp);
sum1=sum(Atemp2,1);
sum2=sum(Atemp2,2);
no=1;
nn = ntemp-1;
A10 = Atemp(:,1);
A12 = Atemp(:,2:end);
xo = xtemp(1,:);
x = xtemp(2:end,:);

% % pipe diameters: set in mine_geothermal
% d   = 4*ones(np,1);