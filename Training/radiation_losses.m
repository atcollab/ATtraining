 % Losses = Cgamma/2/pi*EGeV^4*I2
    cgamma=4e9*pi*PhysConstant.classical_electron_radius.value/3/...
        PhysConstant.electron_mass_energy_equivalent_in_MeV.value^3; % [m/GeV^3]
   
    losses=atgetfieldvalues(ring(atgetcells(ring,'I2')),'I2');
    I2=nbper*(sum(abs(theta.*theta./lendp))+sum(losses));            % [m-1]
    %                bending ang.   lenght of b_magnet
    U0=cgamma/2/pi*(energy*1.e-9)^4*I2*1e9;                          % [eV]
    %          energy in ring        ^
    %                         sync integral