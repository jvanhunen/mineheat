 function [H Q] = mineflow(nn, no, np, x, xo, A12, A10, Ho, L, d)
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
% fixed fluxes: all set to zero, not sure if it works if non-zero!!
q    = zeros(nn,1);
% flow powerlaw exponent ( called B in EPANET manual, p.30, and n in
%                          (Todini&Paliti, 1987))
B    = 2;  % Not sure if eqns below are valid if B is not 2!
I    = eye(np);
Ninv = 1./B*I;
A21  = A12';

% Start iterative calculation using Newton method: 
sumdQrel=1e10;
figure(1), clf
while (sumdQrel>1e-8)
    sumdQrel
    for ip=1:np
        % calc resistance coeff using Darcy-Weisbach formula
        %    (EPANET manual p.30 & Table 3.1)
        r(ip) = res_coef(Q(ip),L(ip),d(ip)); 
        % Inverse of A11 as in Eqn 7 of (Todini&Paliti, 1987) 
        A11inv(ip,ip) = (r(ip)*(abs(Q(ip)))^(B-1))^-1; 
    end

    % Solving Eqn 18 of (Todini&Paliti, 1987):
    A = -(A21*Ninv*A11inv*A12);
    F = A21*Ninv*(Q + A11inv*A10*Ho) + q - A21*Q;
    Hnew = A\F;

    % Solving Eqn 19 of (Todini&Paliti, 1987):
    Qnew = (I-Ninv)*Q - Ninv*A11inv*(A12*Hnew + A10*Ho);
    
    % Calculate difference in Q between iterations:
    avQ = sum(abs(Qnew))/length(Qnew);
    dQrel = abs((Q-Qnew)./avQ);
    sumdQrel = sum(dQrel);
    
    % prepare for next iteration:
    H=Hnew;
    Q=Qnew;
end