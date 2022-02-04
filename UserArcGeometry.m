function [nn, no, np, A12, A10, xo, x] = UserArcGeometry(UserShapefile)

%%%% Step 1- Read mine plans in from ArcGis shapefile

S = shaperead(UserShapefile);

%%%% S is an object with attiributes as follows:
%%%%
%%%% S.Geometry
%%%% S.X
%%%% S.Y
%%%% S.Join_Count
%%%% S.TARGET_FID
%%%% S.POINT_X
%%%% S.POINT_Y
%%%% S.NODEID
%%%% S.EXT_MIN_X
%%%% S.EXT_MIN_Y
%%%% S.EXT_MAX_X
%%%% S.EXT_MAX_Y
%%%% S.PIPEID

%%%% 
sizeofS = size(S);
npoints = sizeofS(1);
flow_dir = zeros(npoints,1);


%%%% Loop over nodes, and determine if node is inflow or outflow
for ipoint = 1:npoints
    
    %%%% Outflow node condition
    if (S(ipoint).POINT_X == S(ipoint).EXT_MIN_X && S(ipoint).POINT_Y == S(ipoint).EXT_MIN_Y)
       flow_dir(ipoint) = -1; 
    end
    
    %%%% Inflow node condition
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
A11inv = sparse(np,np);
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

%%%% To generate A10 and A12, generate A for ALL nodes and pipes. Select
%%%% node number for 'known' heads and extract columns of Atempp. These
%%%% give A10, remaining columns give A12.

% Atemp2 = abs(Atemp);
% sum1=sum(Atemp2,1);
% sum2=sum(Atemp2,2);
no=1;
nn = ntemp-1;
A10 = Atemp(:,1);
A12 = Atemp(:,2:end);
xo = xtemp(1,:);
x = xtemp(2:end,:);

% % pipe diameters: set in mine_geothermal
% d   = 4*ones(np,1);