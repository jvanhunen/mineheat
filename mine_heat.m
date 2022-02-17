function [Tn Tp rp] = mine_heat(nyrs, d, L, Q, v, np, nn, no, Tf_ini,...
        k_r, Cp_r, rho_r, Tr, npipes, node_pipes_in, node_pipes_out, pipe_nodes,...
        xtotal,PhysicalProperties,testbank, x, xo, n_tree, n_tree_idx) 
    %        k_r    = thermal conductivity     [
    %        Cp_r   = heat capacity            [
    %        rho_r  = density                  [kg m^-3]
    %        Tf_ini = water inflow temperature [oC]
    %        Tr     = Initial rock temperature [oC]
    %        d      = Pipe diameter            [m]
    %        nyrs   = flow duration            [yrs]
    %        L      = pipe lengths             [m]
    %        Q      = pipe flow                [m^3 s^-1]
    %        v      = pipe flow velocity       [m s^-1]
    %        np     = number of pipes          [units]
    %        nn     = number of unknown head nodes  [units]
    %        no     = number of known head nodes    [units]
    %        npipes = (2, no+nn) number of incoming or outgoing pipes at each
    %        node.
    %        node_pipes_in/out = (maxnpipes_in+1,nn+no) array of all pipes
    %        entering/exiting each node.
    %        pipe_nodes  = (np,2) array to store start & end node of each pipe
    %        n_tree = (nn+no,1) array to store all connected nodes based on
    %        downstream flow.
    %        n_tree_idx = (nn+no,1) maps the node to its index in the
    %        n_tree array. Useful to check if a node is in the flow path.
    %        
    % version 20220217
    %    JMC replaced heat computation using downstream tree.
    % version 20210720 
    %    added warning for max nr iterations exceeded.
    % version 20210712
    %    added verbose option for more debug information
    %    addressed weird (but harmless) pipe temperatures in case of zero or 
    %       extremely slow pipe flows (e.g. in dead-end roadways). 
    
    % More output needed? --> Set verbose to 1.
    verbose = 0;
    
    t = 3600*24*365*nyrs;
    r=d./2;
    
    % First, set T of all incoming nodes:
    Tn = zeros(nn+no,1);
    Tp = zeros(np, 2);
    rp = zeros(np, 1); %radius from which heat is extracted around the pipe
    
    % Impose inflow temperature on nodes that have external inflow
    % (which will be updated later with T from inflowing pipes if applicable)
    weighted_flow_in = zeros(np,1);
    Qmax = max(abs(Q));
    for inode = 1:nn+no
        sumQ = 0.;
        sumQin = 0.;
        sumQout = 0.;

        Tn(inode) = Tr; % Sets all nodes to the background rock temp
        
        % Flow balance
        external_inflow=0.;
        npipe_in = npipes(1,inode);
        % If node has inflow pipes, sum that inflow
        if npipe_in>0
            sumQin = sum(Q(node_pipes_in(1:npipe_in,inode)));
        end

        npipe_out = npipes(2,inode);
        % If node has outflow pipes, sum outflow
        if npipe_out>0
            sumQout = sum(Q(node_pipes_out(1:npipe_out,inode)));
        end
        % compute difference between in and outflow
        sumQ = sumQin - sumQout;
        if (sumQ/Qmax<-1e-6) % significant external inflow at node: 
            external_inflow = -sumQ;
            Tn(inode)=Tf_ini*external_inflow/(sumQin+external_inflow);  % Give all these nodes initial inflow T at first
        end
            %         elseif (sumQin/Qmax<1e-6 && sumQout/Qmax<1e-6) % no significant in or outflow: stagnant point, set T=Tr
%             Tn(inode) = Tr;
%         end
        % If more than 1 pipe flows into node, then T of node will be a weighted
        % average of the T of those inflowing pipes.
        % Those weights are stored in weighted_flow_in
        weighted_flow_in(node_pipes_in(1:npipe_in,inode)) = Q(node_pipes_in(1:npipe_in,inode))/(sumQin+external_inflow);
    end
    
    % Solves for the system temperature using the n_tree which ensures
    % that when every node is solved all the required inflow Temps have already
    % been calculated.    
    for i = 1:length(n_tree)
        in = n_tree(i);
        
        % checks if end of tree reached
        if n_tree(in) == 0
            break;
        end

        % Because all the nodes are set to Tr initially, if a node is still
        % set to Tr (i.e. not overriden by inflow T), then set it to 0
        % because its full temperature will be determined in this iteration
        if Tn(in) == Tr
            Tn(in) = 0;
        end
        
        % iterates through the current node's incoming pipes 
        pipes = transpose(node_pipes_in(1:npipes(1,in), in));
        for j = 1:length(pipes)
            ip = pipes(j);
            fn = pipe_nodes(ip,1); % the inflow node at the other end of the pipe
            %  (start of pipe ip) fn ---ip---> in (end of pipe ip)
            Tp(ip,1) = Tn(fn); % this will work because any edge nodes will be at Tr
            [Tp(ip,2), rp(ip,1) ]= pipeheat(r(ip), L(ip), Tn(fn),...
                k_r, Cp_r, rho_r, Tr, v(ip), t,PhysicalProperties,testbank);
    
            if (verbose) 
                fprintf('Solved T for pipe %d: T= %f -> %f\n',ip,Tp(ip,1),Tp(ip,2))
            end
            % T at end of pipe contributes to T at node at end of pipe:
            Tn(in) = Tn(in) + weighted_flow_in(ip)*Tp(ip,2);
            if Tn(in) > Tr+Tr*0.01
                fprintf('WARNING Node %d Temperature = %f , which is greater than Tr = %f\n',in, Tn(in), Tr);
            end
            %fprintf("Tinlet = %e, Tout= %e\n", Tn(fn), Tn(in));
        end 
    end
end

