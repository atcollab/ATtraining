function [ring, arc] = dba()

Ncells = 24 ; %actually it is 50 half cells
K_QF1 = 0.38041; %Strength of the quadrupoles
K_QD2 = -0.2708;
K_QD3 = -0.33319;
K_QF4 = 0.4588;

Ks = 0.1; % Strength of the sextupoles
L1 = 3; %

% get arc lattice structure
arc_half={atdrift('DR_01', L1*6/8);...
          atquadrupole('QF1', L1/4, K_QF1);...
          atdrift('DR_02', L1*2/8);...
          atquadrupole('QD2', L1/4, K_QD2);...
          atdrift('DR_03', L1*2/8);...
          atrbend('Bend', L1, 2*pi/(2*Ncells));   ...       
          atdrift('DR_04', L1/16);...
          atquadrupole('QD3', L1/4, K_QD3);...
          atdrift('DR_05', L1/16);...
          atsextupole('SD', L1/16, -Ks);...
          atdrift('DR_06', L1*3/16);...
          atquadrupole('QF4', L1/4, K_QF4);...
          atdrift('DR_07', L1/16);...
          atsextupole('SF', L1/4, Ks);...
          };

% make one cell
arc = [arc_half;...
    arc_half(end:-1:1); atmonitor('BPM'); atcorrector('Cor',0.0,[0, 0])];

% make ring and add RF
ring = [repmat(arc,Ncells,1);{atrfcavity('RFC',0,0,0,0)}];

% set energy
ring = atsetenergy(ring,3e9);

% set cavity
ring = atsetcavity(ring,1e6,0,992);

% fit chrom
ring = atfitchrom(ring,[1.0, 2.0],'SF','SD');
ring = atfitchrom(ring,[1.0, 2.0],'SF','SD');

% fit tunes
ring = atfittune(ring,[19.35, 4.60],'QF1\w*','QD2\w*','UseIntegerPart');
% ring = atfittune(ring,[19.35, 4.60],'QF1','QD2','UseIntegerPart',true);

arc = ring(1:length(arc));

disp('sum(angle) - 2pi');
sum(atgetfieldvalues(ring,atgetcells(ring,'BendingAngle'),'BendingAngle'))-2*pi

end