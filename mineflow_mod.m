 function [H Q] = mineflow_mod(nn, no, np, x, xo, A12, A10, Ho, L, d)
% 
% version:
% 20190628: renamed to mineflow
% 20190623: pipeflow4 now is a subfunction: 
%           geometry is set elsewhere and is now function input 
% 20190621: try parallel pipes
% 20190620: generalised from pipeflow2 for n points
% 

%%% Internal parameters to solve for flow:
% Set initial guess for Q
H    = zeros(nn,1);
Q    = ones(np,1);
% Fluid resistance coefficient
r    = zeros(np,1);
% fixed fluxes: all set to zero, not sure if it works if non-zero!!
q    = zeros(nn,1);
% flow powerlaw exponent
B    = 2;
I    = eye(np);
Ninv = 1./B*I;
A21  = A12';

% Start iterative calculation using Newton method: 
sumdQrel=1e10;
figure(1), clf
while (sumdQrel>1e-8)
    sumdQrel
    for ip=1:np
        r(ip) = res_coef(Q(ip),L(ip),d(ip));
        A11inv(ip,ip) = (r(ip)*abs(Q(ip)))^-1;
    end

    A = -(A21*Ninv*A11inv*A12);

    a = A11inv*A10;
    
    F = A21*Ninv*(Q + A11inv*A10*Ho) + q - A21*Q;

    Hnew = A\F;

    Qnew = (I-Ninv)*Q - Ninv*A11inv*(A12*Hnew + A10*Ho);
    avQ = sum(abs(Qnew))/length(Qnew);
    dQrel = abs((Q-Qnew)./avQ);
    sumdQrel = sum(dQrel);
    H=Hnew;
    Q=Qnew;
end