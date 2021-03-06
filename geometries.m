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
function [nn, no, np, A12, A10, xo, x, Ho, q, idiagn] = geometries(igeom,varargin) %qset,q_in,q_out)
% Set mine geometry, fixed hydraulic heads, and external flow constraints:
%  - geometry (node locations & pipe connections) in function geometryX
%  - fixed hydraulic heads of all nodes xo
%  - external in/outflow for all nodes x



% version 202201013 SG:
%    ArcGeometry now takes the shapefile as an argument, rather than
%    specified in the file.
%       
%    New case introduced 'UserArcGeometry-CommandLinePrompt'

% version 20220106 SG:
%    igeom model identifier placed in a switch-case loop rather than an if
%    statement - switch will allow only one model per ID, this is not garanteed
%    with an if statement. Due to modifications to mine_plots.m, igeom can
%    now be a string or a double.

% version 20210720 JvH:
%    added idiagn option to output parameters


head   = 1e-7;     % hydraulic head loss through mine (m). e.g. 6.3e-12
                   %%% Where we apply it is arbitrary
switch igeom
    case 1
        % Benchmark 1: linear pipesystem of open pipes:
        [nn, no, np, A12, A10, xo, x] = geometry1();
        % set fixed hydraulic heads:
        Ho     = zeros(no,1);
        Ho(1)  = head;  % ... and by definition,
        Ho(2)= 0;
        % set any external in/outflow for each (non-fixed) node:
        q    = zeros(nn,1);
        idiagn = nn;
        
    case 2
        % Benchmark 2: dual, parallel pipesystem of open pipes:
        [nn, no, np, A12, A10, xo, x] = geometry2();
        % set fixed hydraulic heads:
        Ho     = zeros(no,1);
        Ho(1)  = head;  % ... and by definition,
        Ho(2)=0;
        % set any external in/outflow for each (non-fixed) node:
        q    = zeros(nn,1);
        idiagn = nn;
        
    case 3
        % Benchmark 3: partly dual, parallel pipesystem:
        [nn, no, np, A12, A10, xo, x] = geometry3();
        % set fixed hydraulic heads:
        Ho     = zeros(no,1);
        Ho(1)  = head;  % ... and by definition, Ho(2)=0;
        % set any external in/outflow for each (non-fixed) node:
        q    = zeros(nn,1);
        idiagn = nn;
        
        
    case 4
        % Test 1: small grid:
        [nn, no, np, A12, A10, xo, x] = geometry4();
        % set fixed hydraulic heads:
        Ho     = zeros(no,1);
        Ho(1)  = head; % head;  % ... and by definition,
        Ho(2)= 0;
        % set any external in/outflow for each (non-fixed) node:
        q    = zeros(nn,1);
        idiagn = nn;
        
        
    case 5
        % Test 2: large grid (diss Marijn Huis):
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
        
    case 6
        disp('Running: geometries.m - generating problem geometry')
        % Louisa model (ESII 19/20):
        % diam = 4.0; set in mine_geothermal
        [nn, no, np, A12, A10, xo, x] = louisa_model();
        % set fixed hydraulic heads:
        Ho     = zeros(no,1);
        Ho(1)  = head;  % ... and by definition, Ho(2)=0;
        % set any external in/outflow for each (non-fixed) node:
        q    = zeros(nn,1);
        idiagn = nn;
        
        
    case 7
        disp('Running: geometries.m - generating problem geometry')
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
        
        
    case 8
        %ArcGIS Shapefile Geometry
        [nn, no, np, A12, A10, xo, x] = ArcGeometry('maps/G17P_SpatialJoin12.shp');
        % Check if in/outflow locations fit in nodal space
        
        % set fixed hydraulic heads:
        Ho     = zeros(no,1);
        Ho(1)  = head;
        
      
        % Set inflow/outflow node numbers        
        AskUser = msgbox('Please slect number of inflow/outflow points (max nflows = 4 for igeom 8)');
        waitfor(AskUser);
        
        n_flows = inputdlg('Select number of flowpoints');
        n_flows = str2num(n_flows{1});
        if ismember(n_flows,[1 2 3 4]) == 0;
            error(['n_flows = ' num2str(n_flows) ' invalid. n_flows must be between 1 and 4 inclusive when using igeom = 8'])
        end
        
        % Assing flow nodes from pre-set options
        [q_in, q_out] = testFlows(n_flows);
                  
        if max([q_in{:}]) > nn || max([q_out{:}]) > nn
            error('q_in and/or q_out locations are greater than nodal space of mine model. Choose different q_in and/or q_out.');
        end
        
        qset = varargin{1};  
        
        % set any external in/outflow for each (non-fixed) node:
        q    = zeros(nn,1);
        for i = 1:length(q_in)
            q(q_in{i})  = -qset;
            q(q_out{i}) = qset;
        end
              
        idiagn = nn;
        
        
    case 9
        % ArcGIS shapefile geometry
        [nn, no, np, A12, A10, xo, x] = ArcGeometryZ();

        % Set fixed hydraulic heads 
        Ho = zeros(no,1);
        Ho(1) = 0;
        
        n_flows = 1;            %%%% Dummy variable for now
        
        [q_in, q_out] = testFlows(n_flows);
        
        % Check inflow/outflow locations fit in nodal space
        if max([q_in{:}]) > nn || max([q_out{:}]) > nn
            error('q_in and/or q_out locations are greater than nodal space of mine model. Choose different q_in and/or q_out.');
        end
        
        qset = varargin{1};
        
        q = zeros(nn,1);
        for i = 1:length(q_in)
            q(q_in{i}) = -qset;
            q(q_out{i}) = qset;
        end
        idiagn = nn;
        
    case 10
        % ArcGIS shapefile geometry
        nconnect1 = 9;
        nconnect2 = 9;
        [nn, no, np, A12, A10, xo,x ] = ArcGeometrySecondSeam(nconnect1,nconnect2);
        
        % Set fixed hydraulic heads 
        Ho = zeros(no,1);
        Ho(1) = 0;
        
        n_flows = 1;
        
        [q_in, q_out] = testFlows(n_flows);
        
        % Check inflow/outflow locations fit in nodal space
        if max([q_in{:}]) > nn || max([q_out{:}]) > nn
            error('q_in and/or q_out locations are greater than nodal space of mine model. Choose different q_in and/or q_out.');
        end
        
        qset = varargin{1};
        
        % Set external inflow/outflow for non-fixed nodes
        q = zeros(nn,1);
        for i = 1:length(q_in)
            q(q_in{i}) = -qset;
            q(q_out{i}) = qset;
        end
        idiagn = nn;
        
    case 11
        % ArcGIS shapefile geometry
        nconnect1 = 1240;
        nconnect2 = 2260;
        [nn, no, np, A12, A10, xo, x] = ArcGeometrySecondSeamZ(nconnect1,nconnect2);
        
        % Set fixed hydraulic heads 
        Ho = zeros(no,1);
        Ho(1) = 0;
        
        
        n_flows = 1;
        [q_in q_out] = testFlows(n_flows);
%         q_in = q_in + 1;
%         q_out = q_out+1;
        % Check inflow/outflow locations fit in nodal space
        if max([q_in{:}]) > nn || max([q_out{:}]) > nn
            error('q_in and/or q_out locations are greater than nodal space of mine model. Choose different q_in and/or q_out.');
        end
        
        qset = varargin{1};
        
        % Set external inflow/outflow for non-fixed nodes
        q = zeros(nn,1);
        for i = 1:length(q_in)
            q(q_in{i}) = -qset;
            q(q_out{i}) = qset;
        end
        idiagn = nn;
        
        
    case 101
        [qset q_in q_out, testbank] = varargin{1:end};
        % linear pipesystem with one fixed head, and one prescribed inflow point:
        [nn, no, np, A12, A10, xo, x] = geometry101();

        % set fixed hydraulic heads:
        Ho     = zeros(no,1);
        Ho(1)  = 0; % only-fixed-head node is extraction node.
        
           
        n_flows = 1;
        
        % Initialise flow locations
        q_in  = cell(n_flows,1);
        q_out = cell(n_flows,1);
        
        % Select node locations based on previous input
        switch n_flows
            case 1
                q_in{1}  = 1;
                q_out{1} = 10;
        end
            

        if max([q_in{:}]) > nn || max([q_out{:}]) > nn
            error('q_in and/or q_out locations are greater than nodal space of mine model. Choose different q_in and/or q_out.');
        end            
        
        % set any external in/outflow for each (non-fixed) node:
        q    = zeros(nn,1);
        for i = 1:length(q_in)
            q(q_in{i})  = -qset;
            q(q_out{i}) = qset;
        end
        idiagn = nn;
        
        
    case 102
        [qset q_in q_out] = varargin{1:end};
        % linear pipesystem with one fixed head, and two prescribed in/outflow points:
        [nn, no, np, A12, A10, xo, x] = geometry102();
        % Check if in/outflow locations fit in nodal space
%         if max([q_in{:}]) > nn || max([q_out{:}]) > nn
%             error('q_in and/or q_out locations are greater than nodal space of mine model. Choose different q_in and/or q_out.');
%         end
        % set fixed hydraulic heads:
        Ho     = zeros(no,1);
%         Ho(1)  = 5e-12; % only-fixed-head node is in middle.
        Ho(1) = 0;

        n_flows = 1;
        
        % Initialise flow locations
        q_in  = cell(n_flows,1);
        q_out = cell(n_flows,1);
        
        % Select node locations based on previous input
        switch n_flows
            case 1
                q_in{1}  = 1;
                q_out{1} = 10;
        end
            
        if max([q_in{:}]) > nn || max([q_out{:}]) > nn
            error('q_in and/or q_out locations are greater than nodal space of mine model. Choose different q_in and/or q_out.');
        end         
        
        % set any external in/outflow for each (non-fixed) node:
        q    = zeros(nn,1);
        for i = 1:length(q_in)
            q(q_in{i})  = -qset;
            q(q_out{i}) = qset;
        end
        idiagn = nn+no;
        
        
    case 103      
        [qset q_in q_out,testbank] = varargin{1:end};
        % large grid (diss Marijn Huis):
        n  = 10;   % grid width (number of nodes wide)
        m  = 15;   % grid height (number of nodes high)
        l1 = 100;  % length of horizontal pipes
        l2 = 100;  % length of vertical pipes
        [nn, no, np, A12, A10, xo, x] = geometry103(n , m, l1, l2);
       
        % set fixed hydraulic heads:
        Ho     = zeros(no,1);
        Ho(1)  = 0;

        if testbank == 0
            % Set inflow/outflow node numbers
            AskUser = msgbox('Please slect number of inflow/outflow points (max nflows = 4 for igeom 103)');
            waitfor(AskUser);
            
            n_flows = inputdlg('Select number of flowpoints');
            n_flows = str2num(n_flows{1});
            if ismember(n_flows,[1 2 3 4]) == 0;
                error(['n_flows = ' num2str(n_flows) ' invalid. n_flows must be between 1 and 4 inclusive when using igeom = 8'])
            end
            
        else
            n_flows = 1;
        end
        
        [q_in, q_out] = testFlows(n_flows);

        % Check if in/outflow locations fit in nodal space
        if max([q_in{:}]) > nn || max([q_out{:}]) > nn
            error('q_in and/or q_out locations are greater than nodal space (nn) of mine model. Choose different q_in and/or q_out.');
        end  

        % set any external in/outflow for each (non-fixed) node:
        q    = zeros(nn,1);
        for i = 1:length(q_in)
            q(q_in{i})  = -qset;
            q(q_out{i}) = qset;
        end     

        idiagn = 148;  % not very useful, since there are 2 outlets, not 1.

    case 104
        % ArcGIS shapefile geometry
        nconnect1 = 1240;
        nconnect2 = 2260;
        [nn, no, np, A12, A10, xo, x] = ArcGeometrySecondSeamZ(nconnect1,nconnect2);
        
        % Set fixed hydraulic heads 
        Ho = zeros(no,1);
        Ho(1) = 0;

        % Seting fixed hydraulic heads
        % define the GIS to Matlab array maping index, the values
        % correspond to the Matlab indices, and the indices to the GIS
        % indices. e.g. gis_to_matlab(54) returns the matlab index
        % corresponding to the gis index 54.
        gis_to_matlab = [1:nn+no];
        GIS_no_index = 45;
        gis_to_matlab(45) = nn+no; % we assign the GIS node 45 to the fixed head node index in the matlab array: nn+no
        Ho(gis_to_matlab(45)-nn) = 0; % because Ho is of length no and node nn+no we need to remove nn after the matlab array conversion

        n_flows = 1;
        [q_in q_out] = testFlows(n_flows);
%         q_in = q_in + 1;
%         q_out = q_out+1;
        % Check inflow/outflow locations fit in nodal space
        if max([q_in{:}]) > nn || max([q_out{:}]) > nn
            error('q_in and/or q_out locations are greater than nodal space of mine model. Choose different q_in and/or q_out.');
        end
        
        qset = varargin{1};
        
        % Set external inflow/outflow for non-fixed nodes
        q = zeros(nn,1);
        for i = 1:length(q_in)
            q(q_in{i}) = -qset;
            q(q_out{i}) = qset;
        end
        idiagn = nn;
    
    case 200
        % ArcGIS shapefile geometry
        nconnect1 = 1240;
        nconnect2 = 2260;
        [A120, xtotal, N, np] = GISCONVArcGeometrySecondSeamZ(nconnect1,nconnect2);

        % Specify the number of desired fixed heads
        no = 2;
        nn = N - no;

        % creates a map between GIS indices and Matlab code indices
        internalState.Init(nn,no);
               
        % Set fixed hydraulic heads 
        Ho = zeros(no,1); % creats the internal array of fixed head of size no
        Ho = internalState.SetAsFixedHead(3000, 0, Ho); % sets the GIS node 3000 to the internal fixed head node, with a value of 0 m
        Ho = internalState.SetAsFixedHead(2500, 1e-8, Ho);

        % Adjust A12, xo, x and A10
        [A12, A10] = internalState.MatSetup(A120);
        [x, xo] = internalState.MatSetup(xtotal, 'inv');

        n_flows = 5;
        [q_in q_out] = testFlows(n_flows);
%         q_in = q_in + 1;
%         q_out = q_out+1;
        % Check inflow/outflow locations fit in nodal space
        if max([q_in{:}]) > nn || max([q_out{:}]) > nn
            error('q_in and/or q_out locations are greater than nodal space of mine model. Choose different q_in and/or q_out.');
        end
        
        qset = varargin{1};
        
        % Set external inflow/outflow for non-fixed nodes
        q = zeros(nn,1);
        for i = 1:length(q_in)
            q(q_in{i}) = -qset;
            q(q_out{i}) = qset;
        end
        idiagn = nn;

    case 201
        % Multi-seam model:
        n  = 50;   % grid width (number of nodes wide)
        m  = 50;   % grid height (number of nodes high)
        s  = 3;   % number of seams
        l1 = 100;  % length of horizontal pipes
        l2 = 100;  % length of vertical pipes
        h  = 100;   % interval between seams
        cnx = [10 n*m+5; n*m*2-5 n*m*2+5];% list of connexions between seams
        [A120, xtotal, N, np] = geometry_multigrid(n , m, s, l1, l2, h, cnx);
        
        % Specify the number of desired fixed heads
        no = 1;
        nn = N - no;
        
        % creates a map between GIS indices and Matlab code indices
        internalState.Init(nn,no);
               
        % Set fixed hydraulic heads 
        Ho = zeros(no,1); % creats the internal array of fixed head of size no
        Ho = internalState.SetAsFixedHead(25, 0, Ho); % sets the GIS node 3 to the internal fixed head node, with a value of 0 m


        % Adjust A12, xo, x and A10
        [A12, A10] = internalState.MatSetup(A120);
        [x, xo] = internalState.MatSetup(xtotal, 'inv');

        n_flows = 6;
        [q_in q_out] = testFlows(n_flows);
        % Check inflow/outflow locations fit in nodal space
        if max([q_in{:}]) > nn || max([q_out{:}]) > nn
            error('q_in and/or q_out locations are greater than nodal space of mine model. Choose different q_in and/or q_out.');
        end
        
        qset = varargin{1};
        
        % Set external inflow/outflow for non-fixed nodes
        q = zeros(nn,1);
        for i = 1:length(q_in)
            q(q_in{i}) = -qset;
            q(q_out{i}) = qset;
        end
        idiagn = nn;
        
    case 'UserDefinedGeometry-CommandLinePrompts'
        
        %%%% Ask user how many seams they wish to use
        list = {'Single Seam', 'Two Seams'};
        [indx, ~] = listdlg('ListString',list,'SelectionMode','single');
          
        switch indx
            case 1
                [nn, no, np, A12, A10, xo, x, Ho, q, idiagn] = UserDefinedGeometry(head);
                
            case 2
                [nn, no, np, A12, A10, xo, x, Ho, q, idiagn] = UserDefinedGeometryTwoSeams(head);
                    
        end

end

end