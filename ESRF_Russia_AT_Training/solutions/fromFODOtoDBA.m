% fodo to DBA
close all
clear all

%% Lee presentation on basics of AT


%% fodo only (Fh D Fh)
fodo = Lattice_V1();

figure;
atplot(fodo);
set(gca,'YLim',[0 20]);

%  with 2 periods
fodo2 = [fodo;fodo];
figure;
atplot(fodo2);
set(gca,'YLim',[0 20]);

%% fodo with dipoles
fodo = Lattice_V2();

figure;
atplot(fodo);
set(gca,'YLim',[0 20]);

fodo2 = [fodo;fodo];
figure;
atplot(fodo2);
set(gca,'YLim',[0 20]);

% compute Ex
Ex = computeEx(fodo2);
disp(['Ex : ' num2str(Ex*1e9) ' nm.rad']);

%% fodo with dipoles in low beta region
fodo = Lattice_V3();

figure;
atplot(fodo);
set(gca,'YLim',[0 40]);


fodo2 = [fodo;fodo];
figure;
atplot(fodo2);
set(gca,'YLim',[0 40]);

% compute Ex
Ex = computeEx(fodo2);
disp(['Ex : ' num2str(Ex*1e9) ' nm.rad']);
Ex = computeEx(slicelattice(fodo2));
disp(['Ex : ' num2str(Ex*1e9) ' nm.rad']);

%% add a SS 
fodo = Lattice_V4();

figure;
atplot(fodo);
set(gca,'YLim',[0 40]);


fodo2 = [fodo;fodo(end:-1:1)];
figure;
atplot(fodo2);
set(gca,'YLim',[0 40]);

% compute Ex
Ex = computeEx(fodo2);
disp(['Ex : ' num2str(Ex*1e9) ' nm.rad']);

%% not achromat
fodo = Lattice_V4();
fodo2 = [fodo;fodo(end:-1:1)];

[twiin,~,~] = atlinopt(fodo2,0,1); % get optics at input of no transport line
twiin.Dispersion=[0 0 0 0]';
twidba = twiin;
figure;
atplot(fodo2,'inputtwiss',twiin);
set(gca,'YLim',[0 50]);

% match achromat
fodo = Lattice_V5(twiin);
dba = [fodo;fodo(end:-1:1)];

figure;
atplot(dba);
set(gca,'YLim',[0 50]);

% compute Ex
Ex = computeEx(dba);
disp(['Ex (dba): ' num2str(Ex*1e9) ' nm.rad']);

% full lattice 
ring = repmat(dba,25,1);

p = atgeometry(ring);
figure; 
plot([p.x],[p.y]);
disp('sum angles -2pi');
sum(atgetfieldvalues(ring,atgetcells(ring,'BendingAngle'),'BendingAngle')) - 2*pi

%%
twiin.beta=[15 7];
f = Lattice_V5(twiin);
f2 = [fodo;fodo(end:-1:1)];

figure;
atplot(f2);
set(gca,'YLim',[0 50]);

Ex = computeEx(f2);
disp(['Ex (dba): ' num2str(Ex*1e9) ' nm.rad']);

%% look at phase space (or compute DA)

%run play_with_fodo.m

%% show chromaticity say is not ok for off energy DA
[l,t,c] = atlinopt(ring,0,1);
disp(['chromaticity: ' num2str(c)])

%% add sextupoles (where are they more appropriate?)
[dba,ringsext] = Lattice_V6(twidba);

figure;
atplot(ringsext);
set(gca,'YLim',[0 50]);


%% periodic solution
[dba,ringsext] = Lattice_V6periodic();


%% correct chromaticity (by hand, and then by using either only 2 or both famimlies)
% using only 2 sextupole
% using several sextupoles


%% add a cavity
[dba,ringsext] = Lattice_V7();


