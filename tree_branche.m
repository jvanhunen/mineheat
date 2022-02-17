function [n_in_tree, n_tree_idx, n_tree, np, go_to_next] = tree_branche(cnode, n_in_tree, n_tree_idx, n_tree, np, node_pipes_out, npipes, pipe_nodes)
    % This is a recursive function which creates a tree by connecting the
    % nodes that are connected together by flowing pipes. It allows to
    % reduce the heat computation by avoiding for loops in mineheat.m. It
    % could also be used to establish the mine network's connectivity by
    % checking which nodes are not in the tree using the n_tree_idx.

    verbose = 0;

    [cnode, n_in_tree, n_tree_idx, n_tree, np, go_to_next] = tree_add(cnode, n_in_tree, n_tree_idx, n_tree, np, npipes);
    if verbose == 1
        fprintf('%d pipes leave node %d, and %d flow into it. Next-> %d\n', npipes(2,cnode), cnode, npipes(1,cnode),go_to_next);
    end
    if go_to_next == 1   
        % iterate through all the pipes coming out of cnode
        pipes = transpose(node_pipes_out(1:npipes(2,cnode), cnode));
        for i = 1:length(pipes)
            ip = pipes(i);
            nnode = pipe_nodes(ip,2); % the next node to consider
            if verbose == 1
                fprintf('next node is %d\n', nnode);
            end
            [n_in_tree, n_tree_idx, n_tree, np, go_to_next] = tree_branche(nnode, n_in_tree, n_tree_idx, n_tree, np, node_pipes_out, npipes, pipe_nodes);
        end
    end
    % end of the tree branch reached, go back up to the next valid
                % fork in the tree
end