clear

iterations = 1;

output = ones(iterations,7)*-999;
% Any unfilled output spaces will equal -999


for i=1:iterations
    % Produce random values for variables within their respective ranges
    [kr_in, Cp_in, rho_in, diameter_in, Tr_in] = random_input_mod();
    
    % Input these into mine_geothermal_ensemble
    [Tout, Qout] = mine_geothermal_ensemble_mod(kr_in, Cp_in, rho_in,...
        diameter_in, Tr_in);
    
    % Save outflow temperature and flow rate
    output(i,:) = [Tout, Qout, kr_in, Cp_in, rho_in,...
        diameter_in, Tr_in];
end

disp('')
disp('1st col: Output temperature, deg C')
disp('2nd col: Flow rate, L/s')
disp('3rd col: Rock heat conductivity (W/m,K)')
disp('4th col: Rock specific heat (J/kg,K)')
disp('5th col: Rock density (kg/m^3)')
disp('6th col: Pipe diameters, m')
disp('7th col: Rock initial temperature, degC')
disp(output)
    