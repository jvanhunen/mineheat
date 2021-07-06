function r = res_coef_Brown03(Q,L,d)
   % Calculating resistance coeff of a pipe, using the Darcy-Weisbach
   % formulation as described in Brown, 2003:
   %    r=f*8/(pi^2*g)*L/d^5
   %            f    = the friction factor (p.189 of EPAnet manual)
   %            d    = diameter of the pipe (m)
   %            L    = length of the pipe (m)
   %            g    = gravitational acceleration 
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
   Re  = rho*abs(4*Q/(pi*d^2))*d/mu;
   f = pipe_friction_factor(Re, d, eps);
   g = 9.8;
   r = f*8/(pi^2*g)*L/d^5;
end