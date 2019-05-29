function [dba,ring]=Lattice_V6(twissin)
% Double Bend Achromat cell
% + sextupoles and chromaticity correction
% Matching is required
% (magnets gradient print out)
%
%see also: atfitchrom atmatch atVariableBuilder atlinconstraint

E0 = 3e9;
Ncells = 50;
Kq = 0.1*sqrt(2);
Ks = 0.1;
L = 3; % total cell length = 8*L, circumference = Ncells *8*L

% drifts
Dr = atdrift('Dr',L/8);
Drh = atdrift('Dr',Dr.Length/2);

% dipoles
Bend=atsbend('Bend',L/2,2*pi/(2*Ncells),'PassMethod','BndMPoleSymplectic4Pass','Energy',E0);

% quadrupoles
QF1=atquadrupole('QF1',L/4,+Kq,'PassMethod','StrMPoleSymplectic4Pass','Energy',E0);
QD2=atquadrupole('QD2',L/4,-Kq,'PassMethod','StrMPoleSymplectic4Pass','Energy',E0);
QD3=atquadrupole('QD3',L/4,-Kq,'PassMethod','StrMPoleSymplectic4Pass','Energy',E0);
QF4=atquadrupole('QF4',L/4,+Kq,'PassMethod','StrMPoleSymplectic4Pass','Energy',E0);

%sextupoles
SF=atsextupole('SF',Dr.Length/2,+Ks,'PassMethod','StrMPoleSymplectic4Pass','Energy',E0);
SD=atsextupole('SD',Dr.Length/2,-Ks,'PassMethod','StrMPoleSymplectic4Pass','Energy',E0);


% get arc lattice structure
arc=[...
    {Dr};...
    {Dr};...
    {Dr};...
    {Dr};...
    {Dr};...
    {Dr};...
    {QF1};...
    {Dr};...
    {Dr};...
    {QD2};...
    {Dr};...
    {Dr};...
    {Bend};...
    {Bend};...
    {Drh};...
    {QD3};...
    {Drh};...
    {SD};...
    {Drh};...
    {Drh};...
    {Drh};...
    {QF4};...
    {Drh};...
    {SF};...
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
     3,... verbosity
     @fminsearch,... algorithm
     twissin); % input optics

dba = [arc;arc(end:-1:1)];
 
% fit chromaticity with all sextupoles
[l,t,c] = atlinopt(dba,0,1);
disp(['chromaticity natural (1 cell): ' num2str(c)])

dba = atfitchrom(dba,[0,0],'SF','SD');
dba = atfitchrom(dba,[0,0],'SF','SD');
dba = atfitchrom(dba,[0,0],'SF','SD');

[l,t,c] = atlinopt(dba,0,1);
disp(['chromaticity corrected (1 cell): ' num2str(c)])

% build a full ring
ring = repmat(dba,Ncells/2,1);

figure;
atplot(dba,'inputtwiss',twissin);
set(gca,'YLim',[0 50]);

% display gradients
% quadrupoles
qind = find(atgetcells(dba,'Class','Quadrupole'))';
for iq=1:length(qind)
    disp(['K_' dba{qind(iq)}.FamName '= ' num2str(dba{qind(iq)}.PolynomB(2)) ';% 1/m3']);
end
% sextupoles
qind = find(atgetcells(dba,'Class','Sextupole'))';
for iq=1:length(qind)
    disp(['K_' dba{qind(iq)}.FamName '= ' num2str(dba{qind(iq)}.PolynomB(3)) ';% 1/m3']);
end

end