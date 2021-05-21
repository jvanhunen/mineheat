function r = res_coef(Q,L,d)
   % Calculating resistance coeff of a pipe:
   %      r = 0.0252 ft2m^6 f(eps,d,Q) d^-5 L
   %      with: ft2m = length of foot in metres (0.3048)
   %            f    = the friction factor (p.189 of EPAnet manual)
   %            d    = diameter of the pipe (m)
   %            L    = length of the pipe (m)
   eps = 0.01; % Darcy-Weisbach roughness coeff (e.g. 0.001)
   rho = 1000;  % density of water (kg/m3)
   mu  = 1e-3;  % dynamic viscsoity of water (Pa s)
   Re  = rho*abs(Q)*d/mu;
   ft2m6 = (0.3048)^6; % (length of foot in metres)^6
   f = pipe_friction_factor(Re, d, eps);
   r = 0.0252*ft2m6*f*d^-5*L;
end