function [Tn Tp] = mine_heat(nyrs, d, L, Q, v, np, nn, no, Tf_ini,...
    k_r, Cp_r, rho_r, Tr, npipes, node_pipes_in, node_pipes_out, pipe_nodes,...
    xtotal,PhysicalProperties,testbank,x,xo) 

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


% Solve for T in mine system: 
Tnsolved = zeros(nn+no,1);  % Array to track if node has been fully solved yet.
Tnstuck = zeros(nn+no,1);   % If no outflow;
Tpsolved = zeros(np,1);
nnsolved = 0;
solvedNode = zeros(nn,+no,1);
% First, set T of all incoming nodes:
Tn = zeros(nn+no,1);
Tp = zeros(np, 2);

% Impose inflow temperature on nodes that have external inflow
% (which will be updated later with T from inflowing pipes if applicable)
weighted_flow_in = zeros(np,1);
Qmax = max(abs(Q));
for inode = 1:nn+no                                            %%% Find inflow pipes
    sumQ = 0.;
    sumQin = 0.;
    sumQout = 0.;
    external_inflow=0.;
    
    npipe_in = npipes(1,inode);                                     %%% Get number of pipes flowing into node in
    if npipe_in>0
        sumQin = sum(Q(node_pipes_in(1:npipe_in,inode)));           %%% If there *are* inflow pipes, get sum
    end
    
    
    npipe_out = npipes(2,inode);                                    %%% Get number of pipes flowing out of node in
    if npipe_out>0
        sumQout = sum(Q(node_pipes_out(1:npipe_out,inode)));        %%% If there *are* outflow pipes, get sum
    end
    
    
    sumQ = sumQin - sumQout;                                        %%% Calculate continuity
    if (sumQ/Qmax<-1e-6)                                            %%% Significant external inflow at node in detected
        external_inflow = -sumQ;                                    %%% Assign external inflow rate to the difference
        Tn(inode)=Tf_ini*external_inflow/(sumQin+external_inflow);  %%% Give all these nodes initial inflow T at first
    elseif (sumQin/Qmax<1e-6 && sumQout/Qmax<1e-6)                  %%% No significant in or outflow at node in detected: stagnant point, set T=Tr
        Tn(inode) = Tr;                                             %%% Assign node in rock temperature
                    %%% Partially dealing with the problem, as any issue
                    %%% nodes are already assigned Tr at the start
        
%         Tnsolved(inode)=1;   % Mark these nodes as 'temperature solved' 
%         nnsolved = nnsolved+1;
    end
    % If more than 1 pipe flows into node, then T of node will be a weighted
    % average of the T of those inflowing pipes.
    % Those weights are stored in weighted_flow_in
    weighted_flow_in(node_pipes_in(1:npipe_in,inode)) = Q(node_pipes_in(1:npipe_in,inode))/(sumQin+external_inflow);            %%%% Fraction of total flow at each node that is "inflow"
end

for in=1:nn+no
    if  npipes(1,in)==0   %%% This node has no incoming pipes --> therefore no additional contributions needed, and is NOT on edge of map
        % | (npipes(2,in)==1 & sum(node_pipes_in(:,in) ==0)) 
        
        Tnsolved(in)=1;  
        nnsolved = nnsolved+1; %%% Mark these nodes as 'temperature solved' - means we only need to consider these nodes once in the while loop 
        solvedNode(in) =1;
        
%     elseif npipes(2,in) ==0
%         Tnstuck(in) = 1;            %%% If there are no outflow pipes mark this as a stuck node

    end
end


nitmax=nn+no;
nit=0;

% %%%%% Progressively plot solution
XX = [xo;x];        %%% Get coordinates of nodes
figure()           
clf                 %%% Clear figure from last run
hold on
plot(XX(:,1),XX(:,2),'.','color',[220 220 220]./256)             %%% Plot all nodes in light grey
for p = 1:np
   plot(XX(pipe_nodes(p,:),1),XX(pipe_nodes(p,:),2),'-','color',[220 220 220]./256)
end

scatter(XX(find(Tn~=0),1),XX(find(Tn~=0),2),5,Tn(find(Tn~=0)),'filled')
title({['Nodes assigned Tr prior to'];['"downstream" calaculation of temperatures']})

% axis([min(XX(:,1)) max(XX(:,1)) min(XX(:,2)) max(XX(:,2))])      %%% Set axis to stop constant re-sizing
% axis equal
% 
% plot(XX(find(Tnsolved == 1),1), XX(find(Tnsolved == 1),2),'b.')  %%% Plot nodes assigned solved in previous loop in blue
% plot(XX(find(Tnstuck == 1),1), XX(find(Tnstuck == 1),2),'r.') 
% %%%%%%%%

while (nnsolved<nn+no)  %%% Not all node T's have been solved: continue
    
    
    if nit>=nitmax
        disp('mine_heat: max nr iterations exceeded & not all nodes solved yet: increase nitmax')
        disp('mine_heat: max nr iterations, remaining nodes poorly connected to nextwork')
        break;
    end
    
    nit=nit+1;
    
    for in=1:nn+no                       %%%% loop over all nodes 
        if Tnsolved(in)>= npipes(1,in)   %%%% Find solved inflow pipes from previous loop, 
                                         %%%% 
                                        % The >= will take care of nodes without 
                                        % inflow pipes (Tnsolved set to 1 in previous 
                                        % routine, but npipes(1,...) =0)
                                        
             
            for ip = 1: npipes(2,in) % loop over pipes flowing out of this node
                % pipe number for this pipe: 
                pipenr = node_pipes_out(ip,in);
                % Check if this pipe has not been solved before yet: 
                if Tpsolved(pipenr) == 0
                    Tp(pipenr,1) = Tn(in);
                    Tp(pipenr,2) = pipeheat (r(pipenr), L(pipenr), Tn(in),...
                        k_r, Cp_r, rho_r, Tr, v(pipenr), t,PhysicalProperties,testbank);
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
                        solvedNode(in) = 1;
                    end  
                    
%                         plot(XX(in,1),XX(in,2),'.','color',[11 182 39]./256)
%                         drawnow
%                         pause(0.005)
%                         title(['in = ' num2str(in)])

                end  
            end
        end   
    end
    if (verbose) 
        fprintf('Number of node temperatures solved: %d/%d\n', nnsolved, nn+no)
    end
end

% disp(sum(Tnsolved < npipes(1,:)'))
% [Tn Tnsolved<npipes(1,:)']
   


%  disp(sum(Tnsolved >= npipes(1,:)')+sum(Tnsolved < npipes(1,:)'))
% size(NODES)
% sum(solvedNode ~=1);

% figure()
% scatter(XX(:,1),XX(:,2),5,Tn)
% axis square
% axi
%%%% Deal with unsolved nodes
if nnsolved <nn+no
   for in = 1:nn+no
       if Tn(in) > Tr;
       Tn(in) = Tr;       
       end
       
      if Tnsolved(in) < npipes(1,in)
         for ip = 1:npipes(2,in)
             pipenr = node_pipes_out(ip,in);
             Tp(pipenr,:) = Tn(in);
         end         
      end             
   end          
end

for ip = 1:np
   if Tp(ip,:) == [Tr Tf_ini] | Tp(ip,:) == [Tf_ini Tr]
       Tp(ip,:) = [Tr Tr]; 
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


end


