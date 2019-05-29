function arc=Lattice_V5(twissin)
% lattice with dipoles in low beta regions, straight section and dispersion
% zero. Matching is required
%
%see also: atmatch atVariableBuilder atlinconstraint


E0 = 3e9;
Ncells = 50;
Kq = 0.1*sqrt(2);
L = 3; % total cell length = 8*L, circumference = Ncells *8*L

% drifts
%Dr=atdrift('Dr',L);
%HalfDr=atdrift('Dr',L/2);
Dr = atdrift('Dr',L/4);
%p2Dr=atdrift('Dr',L*2/5);

% dipoles
Bend=atsbend('Bend',L/2,2*pi/(2*Ncells),'PassMethod','BndMPoleSymplectic4Pass','Energy',E0);

% quadrupoles
QF1=atquadrupole('QF1',L/4,+Kq,'PassMethod','StrMPoleSymplectic4Pass','Energy',E0);
QD2=atquadrupole('QD2',L/4,-Kq,'PassMethod','StrMPoleSymplectic4Pass','Energy',E0);
QD3=atquadrupole('QD3',L/4,-Kq,'PassMethod','StrMPoleSymplectic4Pass','Energy',E0);
QF4=atquadrupole('QF4',L/4,+Kq,'PassMethod','StrMPoleSymplectic4Pass','Energy',E0);


% get arc lattice structure
arc=[...
    {Dr};...
    {Dr};...
    {Dr};...
    {QF1};...
    {Dr};...
    {QD2};...
    {Dr};...
    {Bend};...
    {Bend};...
    {Dr};...
    {QD3};...
    {Dr};...
    {QF4};...
    ];


% match optics
var1=atVariableBuilder(arc,'QF1',{'PolynomB',{2}});
var2=atVariableBuilder(arc,'QD2',{'PolynomB',{2}});
var3=atVariableBuilder(arc,'QD3',{'PolynomB',{2}});
var4=atVariableBuilder(arc,'QF4',{'PolynomB',{2}});

% force derivative of beta functions and dispersion to be zero at end of
% cell
c1=atlinconstraint(length(arc)+1,{{'alpha',{1}}},[0],[0],[1]);
c2=atlinconstraint(length(arc)+1,{{'alpha',{2}}},[0],[0],[1]);
c3=atlinconstraint(length(arc)+1,{{'Dispersion',{2}}},[0],[0],[1e-4]);
c4=atlinconstraint(1:(length(arc)+1),{{'beta',{2}}},[0],[40],[1]);

[...
     arc,...
     ~,...
     ~...
     ]=atmatch(...
     arc,...
     [var1 var2 var3 var4],... variables
     [c1 c2 c3 c4],... constraints
     1e-15,... tolerance
     1000,... calls
     0,... verbosity
     @fminsearch,... algorithm
     twissin); % input optics
 
figure;
atplot(arc,'inputtwiss',twissin);
set(gca,'YLim',[0 50]);


end