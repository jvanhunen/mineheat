 function [H Q] = mineflow(nn, no, np, x, xo, A12, A10, Ho, q, L, d)
% 
% This routine solves for the flow in the pipes. The method follows the
% EPANET manual (Appendix D and p.30/Table 3.1), which follows (Todini&Paliti, 1987)
% The 'minor loss coefficient m in EPANET App D is assumed 0
% 
% version:
% 20190628: renamed to mineflow
% 20190623: pipeflow4 now is a subfunction: 
%           geometry is set elsewhere and is now function input 
% 20190621: try parallel pipes
% 20190620: generalised from pipeflow2 for n points
% 

%%% Internal parameters to solve for flow:
% Set initial guess for heads H and flow Q
H    = zeros(nn,1);
Q    = ones(np,1);
% Fluid resistance coefficient (called R in 
r    = zeros(np,1);
% flow powerlaw exponent ( called B in EPANET manual, p.30, and n in
%                          (Todini&Paliti, 1987))
B    = 2;  % Not sure if eqns below are valid if B is not 2!
I    = eye(np);
%Ninv = 1./B*I;
A21  = A12';
A11inv = sparse(np,np);
A11invvec = zeros(np,1);

% Start iterative calculation using Newton method: 
sumdQrel=1e10;
maxdQrel=1e10;
counter = 1;
sumdQrel_arr = zeros(1,1);
while (sumdQrel>1e-8 && maxdQrel>1e-10) %original option was 1e-8
    %disp(['Iteration no.',num2str(counter),', sumdQrel = ',num2str(sumdQrel), ', maxdQrel = ',num2str(maxdQrel)]) 
    for ip=1:np
        % calc resistance coeff using Darcy-Weisbach formula
        %    (EPANET manual p.30 & Table 3.1)
        % r(ip) = res_coef_EPANET(Q(ip),L(ip),d(ip)); 
        r(ip) = res_coef_Brown03(Q(ip),L(ip),d(ip)); 
        % Inverse of A11 as in Eqn 7 of (Todini&Paliti, 1987) 
        A11inv(ip,ip) = (r(ip)*(abs(Q(ip)))^(B-1))^-1; 
    end
    %dA11inv = diag(A11inv);
    % Solving Eqn 18 of (Todini&Paliti, 1987):
    
    %A = -(A21*Ninv*A11inv*A12);
    %tic; disp('   *1')
    A = -(A21*A11inv*A12)/B;
    %toc
    %tic; disp('   *2')
    %F = A21*Ninv*(Q + A11inv*A10*Ho) + q - A21*Q;
    F = A21/B*(Q + A11inv*A10*Ho) + q - A21*Q;
    %toc
    %tic; disp('   *3')
    Hnew = A\F;
    %toc
    %tic; disp('   *4')
    % Solving Eqn 19 of (Todini&Paliti, 1987):
    %Qnew = (I-Ninv)*Q - Ninv*A11inv*(A12*Hnew + A10*Ho);
    Qnew = (1-1/B)*Q - A11inv*(A12*Hnew + A10*Ho)/B;
    %toc
   
    
    % Replace zero flow values with very small nonzero values
    % If Q contains 0 flows this results in divide-by-0 errors
    for i = 1:length(Qnew)
        if Qnew(i) == 0
            Qnew(i) = min(Qnew(Qnew>0))/10;
        end
    end
    
    % Calculate difference in Q between iterations:
    avQ = sum(abs(Qnew))/length(Qnew);
    dQrel = abs((Q-Qnew)./avQ);
    sumdQrel = sum(dQrel);
    maxdQrel = max(dQrel);
    
    % prepare for next iteration:
    a = 0.5; % a+b must equal 1
    b = 0.5; % a+b must equal 1
    Q = a*Q+b*Qnew; % damping oscillation - Q reset
    
    counter = counter + 1;
    sumdQrel_arr(counter,1) = sumdQrel;
    
    % check solution - if stuck in infginite loop the model quits
    num_doubles = 0; % count the number of double numbers in sumdQrel_arr
    for icounter = 1:counter-1
        if round(sumdQrel_arr(counter),5,'significant') == round(sumdQrel_arr(icounter),5,'significant')
            num_doubles = num_doubles + 1;
            if num_doubles > 10 % value to ensure double numbers are not due to chance
                error('Error in flow calculation. Stuck in infinite loop. Consider changing a and b in Q reset in mineflow.m. Decrease a and increase b.');
            end
        end
    end
    
%     if counter > 2500 % || sumdQrel_new >= sumdQrel % prepare for next itrtn
%         save('sumdQrel_arr2','sumdQrel_arr')
%         error('Error in flow calculation. Stuck in infinite loop.');
%     end
end
H=Hnew-min(Hnew);
 end