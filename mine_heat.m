function [Tn Tp] = mine_heat(t, r, L, v, np, nn, no, Tf_ini,...
    k_r, Cp_r, rho_r, Tr, npipes, node_pipes_out, pipe_nodes,...
    weighted_flow_in,xtotal,d) 

% Solve for T in mine system: 
Tnsolved = zeros(nn+no,1);  % Array to track if node has been solved yet.
Tpsolved = zeros(np,1);
nnsolved = 0;
% First, set T of all incoming nodes:
Tn = zeros(nn+no,1);
Tp = zeros(np, 2);
for in=1:nn+no
    if npipes(1,in)==0
        % This node has no incoming pipes:
        Tn(in)=Tf_ini;    % Give all nodes initial inflow T at first
        Tnsolved(in)=1;
        nnsolved = nnsolved+1;
    end
end

nitmax=100;
nit=0;
while (nnsolved<nn+no & nit<nitmax)  % Not all node T's have been solved: continue
    nit=nit+1
    disp('Number of node temperatures solved:')
    disp(nnsolved)
    %pause(0.05)
    for in=1:nn+no      % loop over all nodes 
        if Tnsolved(in)>=npipes(1,in)   %
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
                    % node at end of this pipe:
                    end_node = pipe_nodes(pipenr,2); 
                    % T at end of pipe controibutes to T at node at end of pipe:
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
end

if (nnsolved<nn+no)
    disp('Number of node temperatures to be solved in total:')
    disp(nn+no)
    figure(5), clf
        axis equal
        xlabel('National Grid Easting')
        %xlim([419040 419280])
        ylabel('National Grid Northing')
        %ylim([552620 552940])
        %xtotal = [xo; x];
        dmax = max(d);
        dplot = 2;
            grid on
            hold on 
            colormap(jet)
            caxis([min(min(Tpsolved)) max(max(Tpsolved))]);
            for ip = 1:np
                x1 = xtotal(pipe_nodes(ip,1),1);
                x2 = xtotal(pipe_nodes(ip,2),1);
                y1 = xtotal(pipe_nodes(ip,1),2);
                y2 = xtotal(pipe_nodes(ip,2),2);
                T1 = Tpsolved(ip);
                T2 = Tpsolved(ip);
                z1 = 0;
                z2 = 0;
                x = [x1 x2];
                y = [y1 y2];
                z = [z1 z2];
                col = [T1 T2];
                surface([x;x],[y;y],[z;z],[col;col],... 
                        'facecol','no',... 
                        'edgecol','interp',...
                        'linew',d(ip)/dmax*dplot);
                if (nn<20) 
                    plot(xtotal(:,1), xtotal(:,2),'ko','MarkerSize',10,'MarkerFaceColor', 'k')
                end
                hcb = colorbar;
                title(hcb,'Tpsolved(0|1)')
                %view(2)
            end    
end


