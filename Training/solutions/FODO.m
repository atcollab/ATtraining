function ring=FODO()

Ncells = 10;
Kq = sqrt(2);
Ks = 1e-3;
L = 0.5; % total cell length = 8*L, circumference = Ncells *8*L
E0 = 3e9;
rfv = 5e5 ;

% cavity
RFC=atrfcavity('RFCav',0,0,0,0,E0);

% drifts
Dr=atdrift('Dr',L);
HalfDr=atdrift('Dr',L/2);
p2Dr=atdrift('Dr',L*2/5);

% dipoles
Bend=atsbend('Bend',L,2*pi/(2*Ncells),'PassMethod','BndMPoleSymplectic4Pass','Energy',E0);

% quadrupoles
QFh=atquadrupole('QF',L/2,+Kq,'PassMethod','StrMPoleSymplectic4Pass','Energy',E0);
QDh=atquadrupole('QD',L/2,-Kq,'PassMethod','StrMPoleSymplectic4Pass','Energy',E0);

% sextupoles
SF=atsextupole('SF',0.1,+Ks);
SD=atsextupole('SD',0.1,-Ks);

% get arc lattice structure
arc=[...
    {HalfDr};...
    {Bend};...
    {p2Dr};...
    {SF};...
    {p2Dr};...
    {QFh};...
    {QFh};...
    {Dr};...
    {Bend};...
    {p2Dr};...
    {SD};...
    {p2Dr};...
    {QDh};...
    {QDh};...
    {HalfDr}];

% repeat arc for N cells
ring=repmat(arc,Ncells,1);

% add a single cavity
ring=[{RFC};ring];
ring=atsetcavity(ring,rfv,0,100);

end