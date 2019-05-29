function arc=Lattice_V2()
% create a FODO lattice with dipoles

E0 = 3e9;
Ncells = 50;
Kq = 0.1*sqrt(2);
L = 3; % total cell length = 8*L, circumference = Ncells *8*L

% drifts
%Dr=atdrift('Dr',L);
%HalfDr=atdrift('Dr',L/2);
QuarterDr = atdrift('Dr',L/4);
%p2Dr=atdrift('Dr',L*2/5);

% dipoles
Bend=atsbend('Bend',L/2,2*pi/(2*Ncells),'PassMethod','BndMPoleSymplectic4Pass','Energy',E0);

% quadrupoles
QFh=atquadrupole('QF',L/4,+Kq,'PassMethod','StrMPoleSymplectic4Pass','Energy',E0);
QDh=atquadrupole('QD',L/4,-Kq,'PassMethod','StrMPoleSymplectic4Pass','Energy',E0);


% get arc lattice structure
arc={...
    QFh;...
    QuarterDr;...
    Bend;...
    QuarterDr;...
    QDh;...
    QDh;...
    QuarterDr;...
    Bend;...
    QuarterDr;...
    QFh;...
    };

end