function [Tn Tp] = mine_heat(t, d, L, Q, v, np, nn, no, Tf_ini,...
    k_r, Cp_r, rho_r, Tr, npipes, node_pipes_in, node_pipes_out, pipe_nodes,...
    xtotal) 

% version 20210720 
%    added warning for max nr iterations exceeded.
% version 20210712
%    added verbose option for more debug information
%    addressed weird (but harmless) pipe temperatures in case of zero or 
%       extremely slow pipe flows (e.g. in dead-end roadways). 

% More output needed? --> Set verbose to 1.
verbose = 0;

r=d/2;

% Solve for T in mine system: 
Tnsolved = zeros(nn+no,1);  % Array to track if node has been solved yet.
Tpsolved = zeros(np,1);
nnsolved = 0;
% First, set T of all incoming nodes:
Tn = zeros(nn+no,1);
Tp = zeros(np, 2);

% Impose inflow temperature on nodes that have external inflow
% (which will be updated later with T from inflowing pipes if applicable)
weighted_flow_in = zeros(np,1);
Qmax = max(abs(Q));
for inode = 1:nn+no
    sumQ = 0.;
    sumQin = 0.;
    sumQout = 0.;
    external_inflow=0.;
    npipe_in = npipes(1,inode);
    if npipe_in>0
        sumQin = sum(Q(node_pipes_in(1:npipe_in,inode)));
    end
    npipe_out = npipes(2,inode);
    if npipe_out>0
        sumQout = sum(Q(node_pipes_out(1:npipe_out,inode)));
    end
    sumQ = sumQin - sumQout;
    if (sumQ/Qmax<-1e-6) % significant external inflow at node: 
        external_inflow = -sumQ;
        Tn(inode)=Tf_ini*external_inflow/(sumQin+external_inflow);  % Give all these nodes initial inflow T at first
    elseif (sumQin/Qmax<1e-6 && sumQout/Qmax<1e-6) % no significant in or outflow: stagnant point, set T=Tr
        Tn(inode) = Tr;
%         Tnsolved(inode)=1;   % Mark these nodes as 'temperature solved' 
%         nnsolved = nnsolved+1;
    end
    % If more than 1 pipe flows into node, then T of node will be a weighted
    % average of the T of those inflowing pipes.
    % Those weights are stored in weighted_flow_in
    weighted_flow_in(node_pipes_in(1:npipe_in,inode)) = Q(node_pipes_in(1:npipe_in,inode))/(sumQin+external_inflow);
end

for in=1:nn+no
    if npipes(1,in)==0
        % This node has no incoming pipes:
        Tnsolved(in)=1;   % Mark these nodes as 'temperature solved' 
        nnsolved = nnsolved+1;
    end
end

nitmax=nn+no;
nit=0;
while (nnsolved<nn+no)  % Not all node T's have been solved: continue
    if nit>=nitmax
        disp('mine_heat: max nr iterations exceeded & not all nodes solved yet: increase nitmax')
        break;
    end
    nit=nit+1;
    for in=1:nn+no      % loop over all nodes 
        if Tnsolved(in)>=npipes(1,in)   % The >= will take care of nodes without 
                                        % inflow pipes (Tnsolved set to 1 in previous 
                                        % routine, but npipes(1,...) =0)
            % T in this node known: start process of projecting T downstream:
            for ip = 1: npipes(2,in) % loop over pipes flowing out of this node
                % pipe number for this pipe: 
                pipenr = node_pipes_out(ip,in);
                % Check if this pipe has not been solved before yet: 
                if Tpsolved(pipenr) == 0
                    Tp(pipenr,1) = Tn(in);
                    Tp(pipenr,2) = pipeheat (r(pipenr), L(pipenr), Tn(in),...
                        k_r, Cp_r, rho_r, Tr, v(pipenr), t);
                    Tpsolved(pipenr) = 1;
                    if (verbose) 
                        fprintf('Solved T for pipe %d: T= %f -> %f\n',pipenr,Tp(pipenr,1),Tp(pipenr,2))
                    end
                    % node at end of this pipe:
                    end_node = pipe_nodes(pipenr,2); 
                    % T at end of pipe contributes to T at node at end of pipe:
                    Tn(end_node) = Tn(end_node) + weighted_flow_in(pipenr)*Tp(pipenr,2);
                    % update nr of 'solved' pipes flowing into this node:
                    Tnsolved(end_node) = Tnsolved(end_node) + 1;
                    % If all pipes flowing into this end node are
                    %    calculated, then check this node as 'solved'.
                    if Tnsolved(end_node)>=npipes(1,end_node) 
                        nnsolved = nnsolved + 1;
                    end                    
                end                
            end            
        end   
    end
    if (verbose) 
        fprintf('Number of node temperatures solved: %d/%d\n', nnsolved, nn+no)
    end
end

if (nnsolved<nn+no)
    disp('Number of node temperatures to be solved in total:')
    disp(nn+no)
    disp('Number of node temperatures solved sofar:')
    disp(nnsolved)
%     figure(5), clf
%         axis equal
%         xlabel('National Grid Easting')
%         %xlim([419040 419280])
%         ylabel('National Grid Northing')
%         %ylim([552620 552940])
%         %xtotal = [xo; x];
%         dmax = max(d);
%         dplot = 2;
%             grid on
%             hold on 
%             colormap(jet)
%             caxis([min(min(Tpsolved)) max(max(Tpsolved))]);
%             for ip = 1:np
%                 x1 = xtotal(pipe_nodes(ip,1),1);
%                 x2 = xtotal(pipe_nodes(ip,2),1);
%                 y1 = xtotal(pipe_nodes(ip,1),2);
%                 y2 = xtotal(pipe_nodes(ip,2),2);
%                 T1 = Tpsolved(ip);
%                 T2 = Tpsolved(ip);
%                 z1 = 0;
%                 z2 = 0;
%                 x = [x1 x2];
%                 y = [y1 y2];
%                 z = [z1 z2];
%                 col = [T1 T2];
%                 surface([x;x],[y;y],[z;z],[col;col],... 
%                         'facecol','no',... 
%                         'edgecol','interp',...
%                         'linew',d(ip)/dmax*dplot);
%                 if (nn<20) 
%                     plot(xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
%                 end
%                 hcb = colorbar;
%                 title(hcb,'Tpsolved(0|1)')
%                 %view(2)
%             end    
end


