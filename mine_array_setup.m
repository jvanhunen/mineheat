function [pipe_nodes npipes node_pipes_out node_pipes_in Q] ...
          = mine_array_setup(np, nn, no, A10, A12, pipe_nodes, q, Q) 

%%% Extra output information?
verbose=0;
      
%%% Set up index arrays

% Swap indices if flow is from end to start node:
flow_dir = Q>=0;
for ipipe=1:np
    if flow_dir(ipipe)==0
        dummy               = pipe_nodes(ipipe,1);
        pipe_nodes(ipipe,1) = pipe_nodes(ipipe,2);
        pipe_nodes(ipipe,2) = dummy;
        Q(ipipe)            = -Q(ipipe);
    end
end

if (verbose) 
    disp('Flow direction of pipes:')
    for ipipe=1:np
        fprintf('  pipe %d has Q = %f from pipe %d to %d\n', ipipe, Q(ipipe), pipe_nodes(ipipe,1), pipe_nodes(ipipe,2))
    end
end

% Store nr of incoming and outgoing pipes for every node;
npipes = zeros(2,no+nn); % nr of incoming (first row) and outgoing (2nd row) pipes
for ipipe=1:np
    % pipe ipipe enters node inode:
    inode = pipe_nodes (ipipe,2);
    % So update nr of p
    npipes(1,inode) = npipes(1, inode)+1;
    % pipe ipipe exits node inode:
    inode = pipe_nodes (ipipe,1);
    npipes(2,inode) = npipes(2, inode)+1;
end

% Create arrays to list all pipes entering/exiting every node:
maxnpipes_in   =(max(npipes(1,:)));
node_pipes_in  = zeros(maxnpipes_in+1,nn+no); % add 1 to maxnpipes_in to allow for potential external inflow (stored in array q)
maxnpipes_out  =(max(npipes(2,:)));
node_pipes_out = zeros(maxnpipes_out,nn+no);

% Populate 2-D array of all pipes exiting every node:
for ipipe=1:np
    % node inode at start of pipe ipipe:
    inode = pipe_nodes (ipipe,1);
    % add this pipe to the table of all pipes exiting node inode:
    % pipe not yet added to node_pipes_out array:
    pipe_reported = 0;
    % pipe to be added in one of the reserved places in array:
    for ipipe2=1:maxnpipes_out
        if pipe_reported == 0 
            if node_pipes_out(ipipe2,inode) == 0
                % location in array still free, so enter pipe nr here:
                node_pipes_out(ipipe2,inode) = ipipe;
                % and flag pipe as entered
                pipe_reported = 1;
                % leave the ip loop
                break;
            end
        end
    end
end

% Create 2-D array of all pipes entering every node:
for ipipe=1:np
    % node at end of pipe ipipe:
    inode = pipe_nodes (ipipe,2);
    % add this pipe to the table of all pipes entering node in:
    % pipe not yet added to node_pipes_in array:
    pipe_reported = 0;
    % pipe to be added in one of the reserved places in array:
    for ipipe2=1:maxnpipes_in
        if pipe_reported == 0 
            if node_pipes_in(ipipe2,inode) == 0
                % location in array still free, so enter pipe nr here:
                node_pipes_in(ipipe2,inode) = ipipe;
                % and flag pipe as entered
                pipe_reported = 1;
                % leave the ip loop
                break;
            end
        end
    end 
end

% Some nodes have external inflow, which needs recording too: 
for inode = 1:nn
    if q(inode)<0    % external inflow into (free-pressure) node
        % add this info to the node_pipes_in array
        external_inflow_reported = 0;
        % external inflow to be added in one of the reserved places in array
        % find first 'empty' location, and add a -1 there (to indicate external inflow): 
        for index=1:maxnpipes_in
            if external_inflow_reported == 0 
                if node_pipes_in(index,inode) == 0
                    % location in array still free, so enter a -1 here:
                    node_pipes_in(index,inode) = -1;
                    % and flag pipe as entered
                    external_inflow_reported = 1;
                    % leave the index loop
                    break;
                end
            end
        end   
    end
end



