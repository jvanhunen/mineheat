function [n_tree_idx, n_tree, np] = tree_branche(cnode, n_tree_idx, n_tree, np, node_pipes_out, node_pipes_in, npipes, pipe_nodes, Q)
    % This is a recursive function which creates a tree by connecting the
    % nodes that are connected together by flowing pipes. It allows to
    % reduce the heat computation by avoiding for loops in mineheat.m. It
    % could also be used to establish the mine network's connectivity by
    % checking which nodes are not in the tree using the n_tree_idx.
    verbose = 0;

    % Prints out VTK files to highlight the tree formation every time 5
    % nodes are added to it
    global xtotal;
    if verbose ==1 && mod(np-1,5) == 0
        inTree = n_tree_idx;
        inTree(inTree > 0) = 1; 
        vtk_factory("tree_formation_", np, np, pipe_nodes, xtotal, {inTree, npipes}, ["InTree", "Nconnections"], {}, {});
    end

    [cnode, n_tree_idx, n_tree, np, go_to_next] = tree_add(cnode, n_tree_idx, n_tree, np, npipes, node_pipes_in, pipe_nodes, Q);
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
            [n_tree_idx, n_tree, np] = tree_branche(nnode, n_tree_idx, n_tree, np, node_pipes_out, node_pipes_in, npipes, pipe_nodes, Q);
        end
    end
    % end of the tree branch reached, go back up to the next valid
                % fork in the tree
end