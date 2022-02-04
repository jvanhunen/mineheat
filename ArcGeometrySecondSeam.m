function [nn, no, np, A12, A10, xo, x] = ArcGeometrySecondSeam(nconnect1,nconnect2)

T1 = shaperead('maps/UpperSeamShape.shp');
sizeofT1 = size(T1);
npoints1 = sizeofT1(1);
flow_dir1 = zeros(npoints1,1);
for ipoint = 1:npoints1
    if (T1(ipoint).POINT_X == T1(ipoint).EXT_MIN_X && T1(ipoint).POINT_Y == T1(ipoint).EXT_MIN_Y)
       flow_dir1(ipoint) = -1; 
    end
    if (T1(ipoint).POINT_X == T1(ipoint).EXT_MAX_X && T1(ipoint).POINT_Y == T1(ipoint).EXT_MAX_Y)
       flow_dir1(ipoint) = 1;   
    end
end
max_node_id1 = 0;
for ipoint = 1:npoints1
    if T1(ipoint).NODEID > max_node_id1
        max_node_id1 = T1(ipoint).NODEID;
    end
end

ntemp1 = max_node_id1;

max_pipe_id1 = 0;
for ipoint = 1:npoints1
    if T1(ipoint).PIPEID > max_pipe_id1
        max_pipe_id1 = T1(ipoint).PIPEID;
    end
end
np1 = max_pipe_id1;

T2 = shaperead('maps/LowerSeamShape.shp');
sizeofT2 = size(T2);
npoints2 = sizeofT2(1);
flow_dir2 = zeros(npoints2,1);
for ipoint = 1:npoints2
    if (T2(ipoint).POINT_X == T2(ipoint).EXT_MIN_X && T2(ipoint).POINT_Y == T2(ipoint).EXT_MIN_Y)
       flow_dir2(ipoint) = -1; 
    end
    if (T2(ipoint).POINT_X == T2(ipoint).EXT_MAX_X && T2(ipoint).POINT_Y == T2(ipoint).EXT_MAX_Y)
       flow_dir2(ipoint) = 1;   
    end
end
max_node_id2 = 0;
for ipoint = 1:npoints2
    if T2(ipoint).NODEID > max_node_id2
        max_node_id2 = T2(ipoint).NODEID;
    end
end

ntemp2 = max_node_id2;

max_pipe_id2 = 0;
for ipoint = 1:npoints2
    if T2(ipoint).PIPEID > max_pipe_id2
        max_pipe_id2 = T2(ipoint).PIPEID;
    end
end
np2 = max_pipe_id2;

% size of problem:
no  = 1;       % nr of fixed head nodes

% Parameters to be solved in this function:
np = np1+np2+1
ntemp = ntemp1+ntemp2
Atemp = zeros(np,ntemp);
A11inv = zeros(np,np);
xtemp   = zeros(ntemp,3);

% locations of nodes

for ipoint = 1:npoints1
    nodeid = T1(ipoint).NODEID;
    xtemp(nodeid,:) = [T1(ipoint).POINT_X,T1(ipoint).POINT_Y,0];
end
for ipoint = 1:npoints2
    nodeid = ntemp1+T2(ipoint).NODEID;
    xtemp(nodeid,:) = [T2(ipoint).POINT_X,T2(ipoint).POINT_Y,0];
end
% In linear pipe configuration, for each node in, pipe in feeds into 
% node in, and pipe in+1 leaves node in:

for ipoint = 1:npoints1
    nodeid = T1(ipoint).NODEID;
    pipeid = T1(ipoint).PIPEID;
    Atemp(pipeid,nodeid) = flow_dir1(ipoint);
end
for ipoint = 1:npoints2
    nodeid = ntemp1+T2(ipoint).NODEID;
    pipeid = np1+T2(ipoint).PIPEID;
    Atemp(pipeid,nodeid) = flow_dir2(ipoint);
end

Atemp(np,nconnect1)=1;
Atemp(np,nconnect2+ntemp1)=-1;
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
end