function h = heat_transfer_coeff (k, r, v, nu, rho, Cp)
% Calculates the effective heat transfer coefficient
% Equation taken from Rodriguez & Diaz, 2009, Eqn 1
% This is based on the Dittus-Boelter eqn
% 
% k = thermal conductivity
% r = pipe radius
% v = fluid flow velocity
% nu = kinematic viscosity
% rho = fluid density
% Cp = fluid heat capacity

coef1 = (2*v*r/nu)^0.8;
coef2 = (rho*Cp*nu/k)^0.43;
h = k/(2*r)*0.021*coef1*coef2;
