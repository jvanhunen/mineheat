function [Tout, r0] = pipeheat (r, l, Tin, k_r, Cp_r, rho_r, Tr, v, t,PhysicalProperties,testbank)
% Calculates temperature change in pipe segment due to 
% heat exchange with pipe wall
% method from (Rodriguez & Diaz, 2009)
% JMC updated it to subsegment the pipe in small intervals

il = 1; % pipe segment interval length
il = min(il,l); % ensures il isn't longer than the pipe itself
verbose = 0;

if (testbank == 1 || testbank == 1)
    % Fluid properties - testbank 
    k_f   = 0.58;     % water heat conductivity (W/m,K)
    nu_f  = 1.2e-6;   % water kinematic viscocity (m^2/s)
    rho_f = 1000;     % water density (kg/m^3)
    Cp_f  = 4186;     % water specific heat (J/kg,K)
else
    % Fluid properties - user specified
    k_f = PhysicalProperties.k_f;       % water heat conductivity (W/m,K)
    nu_f = PhysicalProperties.nu_f;     % water kinematic viscocity (m^2/s)
    rho_f = PhysicalProperties.rho_f;   % water density (kg/m^3)
    Cp_f = PhysicalProperties.Cp_f;     % water specific heat (J/kg,K)
end


VF = pi*r^2*v;    % fluid flux = cross_pipe surface * velocity (m^3/s)

% fluid heat_transfer_coeff
h_f = heat_transfer_coeff (k_f, r, v, nu_f, rho_f, Cp_f);

% Update r0 = radius of rock surrounding pipe that cooled using one of two methods:
% 1) Original method from (Rodriguez and Diaz, 2009), Equation A17.
% 2) Improved version of this:
%     a) Revised calculation of total ground heat release Equation A12
%     b) Avoid assumption in r0-derivation that T_pi = (T0+T_e)/2
imethod = 2;
if imethod == 1
    r0 = r*sqrt(1+4*h_f/(rho_r*Cp_r*r)*t);
elseif imethod == 2
    r0_in = 2*r;
    niter=1; nitermax=100;
    while 1
        niter = niter + 1;
        if niter>=nitermax
           fprintf('WARNING: pipeheat.m, r0 calc., imethod=2: no convergence in %d iterations\n',niter);
           break;
       end
       L = log(r0_in/r); % Ask JvH for doc showing derivation
       r0_out =  r * sqrt(1 + 4*k_r/(rho_r*Cp_r*r^2)*t + L);
       if abs(r0_in - r0_out)/r0_in<1e-5
           break;
       end
       r0_in = r0_out;
    end
    r0 = r0_out;
end
if verbose
   fprintf(' pipeheat: t=%f, r0=%f\n',t,r0)
end

% effective heat transfer coeff for fluid + wall:
U = (1/h_f + r/k_r*log(r0/r))^-1;

for i = 1:l/il
    % Outflow T using eqn 4 in Rodriguez & Diaz (2009):
    coef1 = 2*pi*r*il*U*Tr;
    coef2 = rho_f*Cp_f*VF;
    coef3 = pi*r*il*U;
    Tout = (coef1 + (coef2-coef3)*Tin) / (coef2+coef3);
    Tin = Tout;
end

if verbose
    L = log (r0/r);
    Tp = (k_r/L*Tr+r*h_f*Tout)/(k_r/L + r*h_f);
    fprintf('   Tw=%f, Tp=%f, T0=%f\n',Tout, Tp, Tr)
end

