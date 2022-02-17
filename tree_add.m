function [cnode, n_in_tree, n_tree_idx, n_tree, tp, go_to_next] = tree_add(cnode, n_in_tree, n_tree_idx, n_tree, tp, npipes)
% This functions adds the node to the tree if it is the last time this node
% will be encountered in the search (this is determined by checking if the
% number of times it has been checked is equal to the number of incoming
% pipes.
%             % Array to store how many attempts at adding the node to the
%             tree have occured
%             n_in_tree = zeros(1,nn+no);
%             % Array to keep track of node index in tree
%             n_tree_idx = zeros(1,nn+no);
%             % Array representing the flow-tree in which to solve for Temp
%             n_tree = zeros(1,nn+no); % note that the end of the tree might
%             be 0 pgo_to_next if not all the nodes are connected to the mine
%             network.
%             % tp is the index of the tree's next vacant position

    verbose = 0;
    % Have we tried adding the node to the tree an amount of
    % time equal to the number of incoming pipes (i.e. is this
    % is now the last time chance to add this node and all
    % incoming nodes have been go_to_next).
    go_to_next = 0;
    
    n_in_tree(cnode) = n_in_tree(cnode) + 1; % increment attempts to add the node to tree counter
    if verbose == 1
        fprintf('node %d requires %d attempts, we are on number %d\n', cnode, npipes(1,cnode), n_in_tree(cnode));
    end
    if npipes(1,cnode) == 0
        go_to_next = 1; % here we set the flag but don't actually add the node to the tree as it is a starting node
    elseif n_in_tree(cnode) == npipes(1,cnode) %we're at the
        % final time the node will be encountered.
        n_tree(tp) = cnode; % adds the node to the tree
        tp = tp+1; % moves the tree position marker to the next free position in the tree
        n_tree_idx(cnode) = tp; % marks the node pos in the tree 
        go_to_next = 1; % to inform the recursive algo that the node has been go_to_next
    end
end
