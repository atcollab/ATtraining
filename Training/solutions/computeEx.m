function ex = computeEx(fodo)
% emittance for 3GeV lattice

dipind = find(atgetcells(fodo,'BendingAngle'))';
dipAng = atgetfieldvalues(fodo,dipind,'BendingAngle');
dipLen = atgetfieldvalues(fodo,dipind,'Length');

[l,~,~] =atlinopt(fodo,0,dipind);
bx = arrayfun(@(a)a.beta(1),l);
dx = arrayfun(@(a)a.Dispersion(1),l);
dxp = arrayfun(@(a)a.Dispersion(2),l);
ax = arrayfun(@(a)a.alpha(1),l);
gx = (1+ax.^2)./bx; % beta*gamma - alpha^2 = 1 

H = bx.*dxp.^2 + 2*ax.*dx.*dxp + gx.*dx.^2;

rho = dipLen./dipAng;

I5 = sum((H'./(abs(rho).^3)).*dipLen);

I2 = sum(1./(rho.^2).*dipLen);

Cq = 3.8319E-13; 
E0 = 3e9; %eV

gamma = (E0*1e-6)/PhysConstant.electron_mass_energy_equivalent_in_MeV.value;

ex = Cq*gamma^2 * I5 / I2;

end
