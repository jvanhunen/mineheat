function [pipe_nodes npipes node_pipes_out node_pipes_in weighted_flow_in Q] ...
          = mine_array_setup(np, nn, no, A10, A12, pipe_nodes, Q) 
%%% Set up index arrays

% Swap indices if flow is from end to start node:
flow_dir = Q>=0;
for ip=1:np
    if flow_dir(ip)==0
        dummy            = pipe_nodes(ip,1);
        pipe_nodes(ip,1) = pipe_nodes(ip,2);
        pipe_nodes(ip,2) = dummy;
        Q(ip) = -Q(ip);
    end
end

% Store nr of incoming and outgoing pipes for every node;
npipes = zeros(2,no+nn); % nr of incoming (first row) and outgoing (2nd row) pipes
for ip=1:np
    % pipe ip enters node in = pipe_nodes (ip,2)
    in = pipe_nodes (ip,2);
    % So update nr of p
    npipes(1,in) = npipes(1, in)+1;
    % pipe ip exits node in = pipe_nodes (ip,1)
    in = pipe_nodes (ip,1);
    npipes(2,in) = npipes(2, in)+1;
end

maxnpipes_in   =(max(npipes(1,:)));
maxnpipes_out  =(max(npipes(2,:)));
node_pipes_in  = zeros(maxnpipes_in,nn+no);
weighted_flow_in = zeros(np,1);
node_pipes_out = zeros(maxnpipes_out,nn+no);

% Create 2-D array of all pipes exiting every node:
for ip=1:np
    % node at start of pipe ip:
    in = pipe_nodes (ip,1);
    % add this pipe to the table of all pipes exiting node in:
    % pipe not yet added to node_pipes_out array:
    pipe_reported = 0;
    % pipe to be added in one of the reserved places in array:
    for ip2=1:maxnpipes_out
        if pipe_reported == 0 
            if node_pipes_out(ip2,in) == 0
                % location in array still free, so enter pipe nr here:
                node_pipes_out(ip2,in) = ip;
                % and flag pipe as entered
                pipe_reported = 1;
                % leave the ip loop
                break;
            end
        end
    end
end

% Create 2-D array of all pipes entering every node:
for ip=1:np
    % node at end of pipe ip:
    in = pipe_nodes (ip,2);
    % add this pipe to the table of all pipes entering node in:
    % pipe not yet added to node_pipes_in array:
    pipe_reported = 0;
    % pipe to be added in one of the reserved places in array:
    for ip2=1:maxnpipes_in
        if pipe_reported == 0 
            if node_pipes_in(ip2,in) == 0
                % location in array still free, so enter pipe nr here:
                node_pipes_in(ip2,in) = ip;
                % and flag pipe as entered
                pipe_reported = 1;
                % leave the ip loop
                break;
            end
        end
    end
end

% If more than 1 pipe flows into node, then T of node will be a weighted
% average of the T of those inflowing pipes.
% Those weights are stored in weighted_flow_in
for in = 1:nn+no
    Qtotal = 0;
    np_in = npipes(1,in);
    if (np_in>0)
        for ip = 1: np_in
            Qtotal = Qtotal + Q(node_pipes_in(ip,in));
        end
        for ip = 1: np_in
            weighted_flow_in(node_pipes_in(ip,in)) = Q(node_pipes_in(ip,in))/Qtotal;
        end
    end
end



