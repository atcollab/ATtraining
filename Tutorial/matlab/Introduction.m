close all; clear;

Ncells = 25; % actually it is 50 half cells

% Strength of the quadrupoles
K_QF1 = 0.38041; 
K_QD2 = -0.2708;
K_QD3 = -0.33319;
K_QF4 = 0.4588;

% Strength of the sextupoles
Ks = 0.1; 
L1 = 3;

%% define elements

% drifts
DR_01=atdrift('DR_01', L1*6/8);
DR_02=atdrift('DR_02', L1*2/8);
DR_03=atdrift('DR_03', L1*2/8);
DR_04=atdrift('DR_04', L1/16);
DR_05=atdrift('DR_05', L1/16);
DR_06=atdrift('DR_06', L1*3/16);
DR_07=atdrift('DR_07', L1/16);

% quadrupoles
QF1=atquadrupole('QF1', L1/4, K_QF1);
QD2=atquadrupole('QD2', L1/4, K_QD2);
QD3=atquadrupole('QD3', L1/4, K_QD3);
QF4=atquadrupole('QF4', L1/4, K_QF4);

% sextupoles
SD=atsextupole('SD', L1/16, -Ks);
SF=atsextupole('SF', L1/4, Ks);

% bend
Bend=atsbend('Bend',L1,2*pi/(2*Ncells));

% BPM
BPM_SS=atmonitor('BPM_SS');
BPM_CellCenter=atmonitor('BPM_CellCenter');

%% create cell and full ring

half_cell_l={DR_01;QF1;DR_02;QD2;DR_03;Bend;DR_04;QD3;DR_05;SD;DR_06;QF4;DR_07;SF};
half_cell_r=half_cell_l(end:-1:1);

full_cell=[half_cell_l;{BPM_CellCenter};half_cell_r;{BPM_SS}];

ring=repmat(full_cell,Ncells,1);


%% plot single cell, plot full ring

figure; 
atplot(full_cell)

figure;
atplot(ring);


%%
mbpm=atgetcells(ring,'Class','Monitor');    % mask
ibpm=find(mbpm);                            % indexes

%% check total bending angle

% find all bending magnets
mb=atgetcells(ring,'Class','Bend');

% or we can search the indexes instead of the mask
ib=findcells(ring,'Class','Bend');

ba=atgetfieldvalues(ring,ib,'BendingAngle');

sum(ba)

%% increase all quadrupoles by 1%

iq=findcells(ring,'Class','Quadrupole');
vq=atgetfieldvalues(ring,iq,'PolynomB',{1,2});

newring=atsetfieldvalues(ring,iq,'PolynomB',{1,2},vq*1.01);

figure; 
atplot(newring)



%% now we want to insert an RF cavity in the lattice
% we put the cavity in the middle of the fourth straight section

% we check how the RF cavity element constructor works

help atrfcavity

harmonic_number=992;
circ=findspos(ring,length(ring)+1);
frf=harmonic_number*299792458/circ;
RFC=atrfcavity('RFC',0,3e6,frf,harmonic_number,3e9,'IdentityPass');


% search SS number 4
iss=findcells(ring,'FamName','BPM_SS');

ring=atinsertelems(ring,iss(3),1,RFC);
ring=atSetRingProperties(ring,'name','DBA','Energy',3e9,'harmonic_number',harmonic_number);

% let's have a look to the ringparam element, the first of the ring
ring{1}

indcav=findcells(ring,'Class','RFCavity');

% off energy lattice
ring_1percent=atsetcavity(ring,'Frequency','nominal','dp',0.01);

ring{indcav}

% radiation on
ringrad=atenable_6d(ring);
ringrad{indcav}

% also the dipoles and quadrupoles pass methods have been changed to
% radpass
ringrad{3}.PassMethod


%% linear optics
% main function to get the linear optics is atlinopt, for 4D lattice
% if the ring is 6d (with a cavity and radiation) we have to use atlinopt6


% I want the linear optics at the bpms, so I search the bpms
ibpm=findcells(ring,'Class','Monitor');

[lindata,t,c]=atlinopt(ring,0,ibpm);
disp(c)
[ringdata,elemdata]=atlinopt6(ringrad,ibpm,'get_chrom');

%% change chromaticity
% chromaticity is very negative, so we correct it

ring=atfitchrom(ring,[1,1],'SF','SD');
ring=atfitchrom(ring,[1,1],'SF','SD');
[lindata,t,c]=atlinopt(ring,0,ibpm);
disp(c)

ringrad=atfitchrom(ringrad,[1,1],'SF','SD');
ringrad=atfitchrom(ringrad,[1,1],'SF','SD');


%% atx and ohmienvelope

[elemdata,beamdata]=atx(ring,0,ibpm);


%% tracking x-x'
coord1=[0.001;0;0;0;0;0];
coord2=[0.002;0;0;0;0;0];
coord3=[0.003;0;0;0;0;0];


coordin=[coord1,coord2,coord3];
nturns=100;

output=ringpass(ringrad,coordin,nturns);
size(output)

timelag1=ringrad{indcav}.TimeLag;

figure;
hold on; grid on;
plot(output(1,:),output(2,:),'.')
xlabel('x (m)')
ylabel('x'' (rad)')


%% tracking longitudinal
coord1=[0;0;0;0;0.001;0];
coord2=[0;0;0;0;0.002;0];
coord3=[0;0;0;0;0.003;0];


coordin=[coord1,coord2,coord3];
nturns=100;

output=ringpass(ringrad,coordin,nturns);
size(output)

figure;
hold on; grid on;
plot(output(6,:),output(5,:),'.')
xlabel('ct (m)')
ylabel('\delta')

%% change phase?
ringrad=atSetCavityPhase(ringrad);
timelag2=ringrad{indcav}.TimeLag;

output2=ringpass(ringrad,coordin,nturns);

figure;
hold on; grid on;
plot(output(6,:),output(5,:),'.','DisplayName',['TimeLag of the RFC = ' num2str(timelag1)]);
plot(output2(6,:),output2(5,:),'.','DisplayName',['TimeLag of the RFC = ' num2str(timelag2,'%1.4f') ' m']);
xlabel('ct (m)')
ylabel('\delta')
legend('Location','NW')


%% change frequency?
nturns_many=10000;
output2=ringpass(ringrad,coordin,nturns_many);
DF=5000; %Hz
ringrad_OffE=atsetcavity(ringrad,'Frequency','nominal','df',DF);

output3=ringpass(ringrad_OffE,coordin,nturns_many);

figure;
hold on; grid on;
plot(output2(5,:),'.','DisplayName',['nominal frequency']);
plot(output3(5,:),'.','DisplayName',['off-frequency +200 Hz']);
xlabel('ct (m)')
ylabel('\delta')
legend('Location','SE')

%%
findorbit6(ringrad)

findorbit6(ringrad_OffE)
