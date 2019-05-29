function ex = computeEX(lattice)
% emittance for 3GeV lattice

%dipLen = 
%dipAng = 

%[l,~,~] =atlinopt(lattice,0,REFPTS);
%bx = betax
%dx = dispersion x
%dxp = dispersion prime x
%ax = alpha x
%gx = (1+ax.^2)./bx; % beta*gamma - alpha^2 = 1 

H = bx.*dxp.^2 + 2*ax.*dx.*dxp + gx.*dx.^2;

rho = dipLen./dipAng;

I5 = sum((H'./(abs(rho).^3)).*dipLen);

I2 = sum(1./(rho.^2).*dipLen);

Cq = 3.8319E-13; 
E0 = 3e9; %eV

gamma = (E0*1e-6)/PhysConstant.electron_mass_energy_equivalent_in_MeV.value;

ex = Cq*gamma^2 * I5 / I2;

end
