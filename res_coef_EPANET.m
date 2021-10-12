function r = res_coef_EPANET(Q,L,d)
   % Calculating resistance coeff of a pipe:
   %      r = 0.0252 ft2m^5 f(eps,d,Q) d^-5 L
   %      with: ft2m = length of foot in metres (0.3048)
   %            f    = the friction factor (p.189 of EPAnet manual)
   %            d    = diameter of the pipe (m)
   %            L    = length of the pipe (m)
   % 
   % Note that this calculation is based on values/formulae for pipes
   %   Not sure how valid this is for mine galleries
   % 
   eps = 0.01; % Darcy-Weisbach roughness coeff (e.g. 0.001)
               % Values listed in EPANET manual Table 3.2, p.31 (in 1e-3 ft!)
               % Note that it is unclear what to choose
               % If eps too high (e.g. 1) then no convergence!
   rho = 1000;  % density of water (kg/m3)
   mu  = 1e-3;  % dynamic viscosity of water (Pa s)
   % Reynolds number = rho*v*d/mu, with v=Q/(pi*r^2) = 4*Q/(pi*d^2)
   %    (for flow in pipe, see https://en.wikipedia.org/wiki/Reynolds_number)
   Re  = rho*abs(4*Q/(3.1415*d^2))*d/mu;
   ft2m5 = (0.3048)^5 % (length of foot in metres)^6
   f = pipe_friction_factor(Re, d, eps)
   d
   L
   r = 0.0252*ft2m5*f*d^-5*L
end