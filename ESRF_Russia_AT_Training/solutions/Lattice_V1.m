function arc=Lattice_V1()
% create a FODO lattice

E0 = 3e9;

Kq = 0.1*sqrt(2);
L = 3; % total cell length = 8*L, circumference = Ncells *8*L

% drifts
Dr=atdrift('Dr',L);
% quadrupoles
QFh=atquadrupole('QF',L/4,+Kq,'PassMethod','StrMPoleSymplectic4Pass','Energy',E0);
QDh=atquadrupole('QD',L/4,-Kq,'PassMethod','StrMPoleSymplectic4Pass','Energy',E0);


% get arc lattice structure
arc={...
    QFh;...
    Dr;...
    QDh;...
    QDh;...
    Dr;...
    QFh;...
    };

end