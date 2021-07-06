function Tout = pipeheat (r, l, Tin, k_r, Cp_r, rho_r, Tr, v, t)
% Calculates temperature change in pipe segment due to 
% heat exchange with pipe wall
% method from (Rodriguez & Diaz, 2009)

% fluid properties
k_f   = 0.58;     % water heat conductivity (W/m,K)
nu_f  = 1.2e-6;  % water kinematic viscocity (m^2/s)
rho_f = 1000;     % water density (kg/m^3)
Cp_f  = 4186;     % water specific heat (J/kg,K)

VF = pi*r^2*v;    % fluid flux = cross_pipe surface * velocity (m^3/s)

% fluid heat_transfer_coeff
h_f = heat_transfer_coeff (k_f, r, v, nu_f, rho_f, Cp_f);

% Update r0 = radius of rock surrounding pipe that cooled:
r0 = r*sqrt(1+4*h_f/(rho_r*Cp_r*r)*t);

% effective heat transfer coeff for fluid + wall:
U = (1/h_f + r/k_r*log(r0/r))^-1;

% Outflow T using eqn 4 in Rodriguez & Diaz (2009):
coef1 = 2*pi*r*l*U*Tr;
coef2 = rho_f*Cp_f*VF;
coef3 = pi*r*l*U;
Tout = (coef1 + (coef2-coef3)*Tin) / (coef2+coef3);
