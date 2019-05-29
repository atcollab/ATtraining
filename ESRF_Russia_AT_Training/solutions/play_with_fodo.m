% start fresh
clear all
close all

%% get lattice in Wrok space
r = FODO;

%% plot lattice
figure;
atplot(r);
figure;
atplot(r,[0 5],'labels',atgetcells(r,'Class','Bend','Quadrupole','Sextupole'));
figure;
atplot(r,[0 5],'index',atgetcells(r,'Class','Bend','Quadrupole','Sextupole'));

%% change tune
rt = atfittune(FODO,[0.2 0.4],'QF','QD');
rt = atfittune(rt,[0.2 0.4],'QF','QD');
rt = atfittune(rt,[0.2 0.4],'QF','QD');

atplot(rt);

%% plot geometry
p = atgeometry(FODO);
figure; plot([p.x],[p.y]);

%% get linear optics
[l0,t0,c0]  = atlinopt(rt,0,1:length(rt)+1);

bx = arrayfun(@(a)a.beta(1),l0);
dx = arrayfun(@(a)a.Dispersion(1),l0);
s = findspos(rt,1:length(rt)+1);

figure; 
plot(s,[bx;dx]);
legend('\beta_x','\eta_x');
xlabel('s [m]');
ylabel(['\beta_x [m], \eta_x [m]']);

% compute CurlyH ?

%% fit chromaticity
[l0,t0,c0]  = atlinopt(rt,0,1:length(rt)+1) ; 
rc = atfitchrom(rt,[0.0 0.0],'SF','SD');
rc = atfitchrom(rc,[0.0 0.0],'SF','SD'); % iterate
rc = atfitchrom(rc,[0.0 0.0],'SF','SD');

[l1,t1,c1]  = atlinopt(rc,0,1:length(rc)+1);

disp('before correction');
disp(c0);
disp('after correction');
disp(c1);

indsext = atgetcells(rc,'FamName','S\w*'); % boolean mask of sextupole indexes
Ks = atgetfieldvalues(rc,indsext,'PolynomB',{1,3}); % read sextupole gradients.

figure; 
bar(Ks);
xlabel('sextupole #');
ylabel('K_{sext} [1/m^2]');

%% get lattice parameters

rp = ringpara(rc)


%% plot phase space 
Nturns = 100;
x0 = [1 0 0 0 0 0]'*(0:1:10)*1e-3;

% avoid irrealistic cases: never track exactly on axis
x0(3,:) = x0(3,:) + 1e-6; % small vertical initial coordinates
x0(5,:) = x0(5,:) + 1e-6; % small initial energy deviation 

% at entrance
tr = ringpass(rc,x0,Nturns);

figure;
plot(tr(1,:),tr(2,:),'.');
xlabel('x [m]');
ylabel('x'' [rad]');

% sextupole off
tr = ringpass(rt,x0,Nturns);

figure;
plot(tr(1,:),tr(2,:),'.');
xlabel('x [m]');
ylabel('x'' [rad]');


% plot phase space at other locations

rrot = atrotatelattice(r,7+1);
rrot{1}
rrot{end}

tr = ringpass(rrot,x0,Nturns);

figure;
plot(tr(1,:),tr(2,:),'.');
xlabel('x [m]');
ylabel('x'' [rad]');

%% plot phase space with RF and radiation
x0 = [1e-6 0 1e-6 0 1e-3 0]';

RADON = 1; 
rrad = atsetcavity(rc,rp.U0*3,RADON,100);

tr = ringpass(rrad,x0,Nturns*10);

figure;
plot(tr(6,:),tr(5,:)*100,'.-');
xlabel('ct [m]');
ylabel('\delta [%]');

figure; plot(tr(5,:)*100)
xlabel('turn #');
ylabel('\delta [%]');

oo = findorbit6(rrad,1:length(rrad)+1);
figure; 
plot(s,oo(5,:)*100)
xlabel('s [m]');
ylabel('\delta [%]');
grid on;

