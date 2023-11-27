%% Simple Optics
%

clear
close all

% add AT in your path
restoredefaultpath;
addpath(genpath('/Users/liuzzo/Documents/EUprojects/EURIZON/ATworkshop/training/at/atintegrators'))
addpath(genpath('/Users/liuzzo/Documents/EUprojects/EURIZON/ATworkshop/training/at/atmat'))
% atmexall;

% generate the example DBA lattice:
[ring, arc] = dba();

%% 6D beam distribution matched to the optics at a specific location 
format long
% from the beam parameters at the desired location 
%                     Hor. beta, alpha, emittance, Ver. beta, alpha, emittance, 
sigma_matrix_4d = atsigma(25.3, 0.0, 6.9e-9, 12.9, 0.0 , 5e-12);
disp(sigma_matrix_4d)

sigma_matrix_6d = atsigma(25.3, 0.0, 6.9e-9, 12.9, 0.0 , 5e-12, 0.0001, 0.006);
disp(sigma_matrix_6d)

% at the first element of a 6D lattice
sigma_matrix_6d_lat = atsigma(atenable_6d(ring));
disp(sigma_matrix_6d_lat) % notice: zero Vertical emittance, so vertical plane is zero.

% add errors and compute new sigma matrix
indquad = find(atgetcells(ring,'Class','Quadrupole'))';
ringerr = atsettilt(ring,indquad,1e-4*randn(size(indquad)));
[a,b] = atx(atenable_6d(ringerr)); % get H/V emittance from lattice with erros
disp('hor emittance nm');
b.modemittance(1)*1e9
disp('ver emittance pm');
b.modemittance(2)*1e12

sigma_matrix_6d_err = atsigma(atenable_6d(ringerr));
disp(sigma_matrix_6d_err) % notice: zero Vertical emittance, so vertical plane is zero.

%% build particles to track

X0 = atbeam(1000, sigma_matrix_6d_err);

lab = {'x','px','y','py','delta','ct'};
figure; 
for i = 1:6
    subplot(3,2,i); histogram(X0(i,:)  ,'DisplayName',[lab{i} ' | ' num2str(std(X0(i,:)))] ); legend;
end

disp('size of X0:')
size(X0)

%% track a single particle element by element

tracks = linepass(ring, X0(:,1), 1:length(ring));
s = findspos(ring,1:length(ring));

figure;
for i = 1:6
    subplot(6,1,i);
    plot(s, tracks(i,:),'.');
    ylabel(lab{i});
end
xlabel('s [m]')

size(tracks)

%% get tune from horizontal and vertical tracking
Nturns = 2^12;
tracks = ringpass(ring, X0(:,1), Nturns);

% get ring properties
rp=atGetRingProperties(ring,'all');

tunes = b.fractunes; % from atx call above

Fs = rp.revolution_frequency;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = Nturns;             % Length of signal
t = (0:L-1)*T;        % Time vector

fx = abs(fft(tracks(1,:)));
fy = abs(fft(tracks(3,:)));

figure;
subplot(5,1,1)
plot(tracks(1,:),'DisplayName','Hor.'); legend;
subplot(5,1,2)
plot(tracks(3,:),'DisplayName','Ver.'); legend;
xlabel('turn');
subplot(5,1,3:5)
ph=plot(1/L*(0:L-1), fx);hold on;
pv=plot(1/L*(0:L-1), fy);
ph.Parent.YScale='log';
pv.Parent.YScale='log';
xlim([0.3,0.45]);
%ylim([0,0.5]);

plot([tunes(1),tunes(1)],[1e-5,1e0],'DisplayName','Hor. tune','Color','c')
plot([1-tunes(2),1-tunes(2)],[1e-5,1e0],'DisplayName','1 - Ver. tune','Color','m')
legend;

%% track a single particle for many turns

tracks = ringpass(ring, X0(:,1), 1000);

figure;
for i = 1:6
    subplot(6,1,i);
    plot(tracks(i,:),'.');
    ylabel(lab{i});
end
xlabel('turn #');


%% track many particle for several turns without radiation

tracks = ringpass(atdisable_6d(ring), ... lattice to use for tracking
    [1, 0, 0.1, 0, 0, 0]'*linspace(0,10,5)*1e-3, ... 6xN initial coordinates
    4000); % number of turns for tracking

figure('Position',[603         878        1867         459]);
subplot(1,3,1);
plot(tracks(1,:),tracks(2,:),'.');
xlabel('x');
ylabel('px');
subplot(1,3,2);
plot(tracks(3,:),tracks(4,:),'.');
xlabel('y');
ylabel('py');
subplot(1,3,3);
plot(tracks(6,:),tracks(5,:),'.');
xlabel('ct');
ylabel('delta');


%% track many particle for several turns with radiation

tracks = ringpass(atenable_6d(ring), ... % lattice to use for tracking
                  [1, 0, 0.1, 0, 0, 0]'*linspace(0,10,5)*1e-3, ... % initial coordinates
                  4000);  % number of turns

figure('Position',[603         878        1867         459]);
subplot(1,3,1);
plot(tracks(1,:),tracks(2,:),'.');
xlabel('x');
ylabel('px');
subplot(1,3,2);
plot(tracks(3,:),tracks(4,:),'.');
xlabel('y');
ylabel('py');
subplot(1,3,3);
plot(tracks(6,:),tracks(5,:),'.');
xlabel('ct');
ylabel('delta');


%% enable/disable 6D
% transform the first drift into a solenoid to get coupled optics
ring{1} = atsolenoid('Sol',ring{1}.Length, 1.0, 'K',0.08); 

ring = atdisable_6d(ring); % set 4D
locations = 1:length(ring); 
s_positions = findspos(ring,locations);
orbit4D = findorbit4(ring,locations);
[ringdata4D, element_by_element_data_4D] = atlinopt4(ring,locations);
ring = atenable_6d(ring);
orbit6D = findorbit6(ring,locations);
[ringdata6D, element_by_element_data_6D] = atlinopt6(ring,locations);

% notice different output for 4D and 6D
ringdata4D
ringdata6D

% notice different output for 4D and 6D
element_by_element_data_4D  
element_by_element_data_6D  % <- additional field R, no fields B, C, gamma

% notice different output for 4D and 6D
element_by_element_data_4D(1).ClosedOrbit  % <- 4x1
element_by_element_data_6D(1).ClosedOrbit  % <- 6x1

figure;
plot(s_positions, orbit4D(1,:),'DisplayName','disable 6d + findorbit4'); hold on;
plot(s_positions, orbit6D(1,:),'DisplayName','enable 6d + findorbit6'); hold on;
legend;
xlabel('s [m]');
ylabel('hor. closed orbit [m]');

% show beta functions
bh_4d = arrayfun(@(a)a.beta(1),element_by_element_data_4D,'un',1);
bh_6d = arrayfun(@(a)a.beta(1),element_by_element_data_6D,'un',1);

figure;
plot(s_positions, bh_4d(1,:),'DisplayName','disable 6d + atlinopt4'); hold on;
plot(s_positions, bh_6d(1,:),'DisplayName','enable 6d + atlinopt6'); hold on;
legend;
xlabel('s [m]');
ylabel('hor. closed orbit [m]');


%% fit tunes

[rd,~] = atlinopt4(ring,1);
disp(['initial tunes: ' num2str(rd.tune)])

desired_tunes = [19.30, 5.20];

disp(['desired tunes: ' num2str(desired_tunes)])

% fit tunes
ring = atfittune(ring,desired_tunes,'QF1\w*','QD2\w*','UseIntegerPart');

[rd,~] = atlinopt4(ring,1);
disp(['fitted tunes: ' num2str(rd.tune)])

% iterate fit tunes
ring = atfittune(ring,desired_tunes,'QF1\w*','QD2\w*','UseIntegerPart');

[rd,~] = atlinopt4(ring,1);
disp(['fitted tunes: ' num2str(rd.tune)])

%% fit chrom
ring = atdisable_6d(ring);

[rd,~] = atlinopt4(ring,1,'get_chrom');
disp(['initial chromaticity: ' num2str(rd.chromaticity)])

desired_chromaticity = [2.0, 5.0];

disp(['desired chromaticity: ' num2str(desired_chromaticity)])

% fit chromaticity
ring = atfitchrom(ring,desired_chromaticity,'SF\w*','SD\w*');

[rd,~] = atlinopt4(ring,1,'get_chrom');
disp(['fitted chromaticity: ' num2str(rd.chromaticity)])

% iterate fit chromaticity
ring = atfitchrom(ring,desired_chromaticity,'SF\w*','SD\w*');

[rd,~] = atlinopt4(ring,1,'get_chrom');
disp(['fitted chromaticity: ' num2str(rd.chromaticity)])


%% optics matching
[~, arc0] = dba();

% some starting optics values
[~, twissin] = atlinopt4(arc0,1);

% set random quad gradients
ind_quad = find(atgetcells(arc0,'Class','Quadrupole'))';
K_quad = atgetfieldvalues(arc0,ind_quad,'PolynomB',{1,2});
arc = atsetfieldvalues(arc0,ind_quad,'PolynomB',{1,2}, ...
    K_quad.*(1+0.01*randn(size(ind_quad)))');

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
     arc_matched,...
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

figure('name','mis-matched'); atplot(arc); pause(1.0);
figure('name','matched'); atplot(arc_matched); pause(1.0);

%% Dynamic Aperture (for quick tests only)
% slurm cluster based functions are available in 
% https://gitlab.esrf.fr/BeamDynamics/ATClusterTools
nturns = 2^7;

[x,y] = atdynap(ring, nturns);
[xp,yp] = atdynap(ring, nturns, 0.01);
[xm,ym] = atdynap(ring, nturns, -0.01);

figure; 
plot(x,y,'DisplayName','dp/p = 0%'); hold on;
plot(xp,yp,'DisplayName','dp/p = +1%')
plot(xm,ym,'DisplayName','dp/p = -1%')
legend;
xlabel('x [m]');
ylabel('y [m]');
