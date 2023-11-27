%% LATTICE MANIPULATIONS
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

% or load it from file
% ring = load('./dba.mat') 

%% plot the optics
figure; atplot(arc);
figure; atplot(ring);
figure; atplot(ring,[15, 25]); 
figure; atplot(ring,[15, 25],@plotB0curlyh); 
figure; atplot(ring,[150, 350],@plClosedOrbit); 

%% plot with given input optics
% [~,twissin] = atlinopt6(ring,1);
% disp(['Original beta: ' num2str(twissin.beta)])
% twissin.beta(1) = 3.0;
% disp(['Modified beta: ' num2str(twissin.beta)])
% figure; atplot(ring,[0, 30],'twiss_in',twissin);

[twissin,~,~] = atlinopt(atdisable_6d(ring),0,1);
disp(['Original beta: ' num2str(twissin.beta)])
twissin.beta(1) = 3.0;
disp(['Modified beta: ' num2str(twissin.beta)])
figure; atplot(atdisable_6d(ring),[0, 30],'twiss_in',twissin);

%% plot ring geometry
p = atgeometry(ring);
figure; plot([p.x],[p.y]);

% p = atgeometry(ring,'centered');
% figure; plot([p.x],[p.y]);
% %%
% p = atgeometry(ring,1:length(ring),'centered');
% figure; plot([p.x],[p.y]);

%% sbreak
figure('Name','initial ring'); atplot(ring,[15, 25]); 
pause(1.0); % correctly plot the magnet layout on the figure above
[newring,refpts]=atsbreak(ring,20.0);
disp('element added by sbreak:')
disp(newring{refpts})
newring{refpts} = atmonitor('BPM');
disp('new element at sbreak position:')
disp(newring{refpts})
figure('Name','sbreak ring'); atplot(newring,[15, 25]); 

%% slice/divide/reduce

% divide an element
disp('before divide')
disp(ring{1})
line = atdivelem(ring{1},[0.5;0.4]);  % notice! no check that sum == 1.0
disp('after divide')
disp(line{1})
disp(line{2})

% slice a lattice
figure('Name','initial ring','Position',[420   917   560   420]); atplot(ring,[0, 25]); 
pause(1.0); % correctly plot the magnet layout on the figure above
ringsplit = splitlattice(ring, 1000);  % not standard AT, based on atdivelem
figure('Name','sliced ring','Position',[985   917   560   420]); atplot(ringsplit,[0, 25]); 
pause(1.0); % correctly plot the magnet layout on the figure above
% atreduce
ringred = atreduce(ringsplit,atgetcells(ring,'FamName','BPM'));  % reduce lattice, but keep BPMs
figure('Name','reduced ring','Position',[1561   917   560   420]); atplot(ringred,[0, 25]); 
pause(1.0);

%% insert/ append/ pop/ remove

indsf = atgetcells(ringred,'FamName','SF');
indbend = atgetcells(ringred,'FamName','Bend');
ringsext = atinsertelems(ringred,indsf,0.5,atmarker('SFcenter'),0.8,[]); % mind, the fractions have to be in increasing order
figure('Name','reduced ring, split sext','Position',[1561   417   560   420]); 
atplot(ringsext,[0, 25],'labels',atgetcells(ringsext,'FamName','SFcenter')); 
pause(1.0);

% append
ring_append = [ring; {atmarker('end')}]; 

% pop
ring_pop = ring(1:end-1); 

% repeat
two_arcs = repmat(arc,[2,1]);
figure; atplot(two_arcs);
pause(1.0)

%% rotate lattice
figure('Name','initial ring','Position',[420   917   560   420]); atplot(arc); 
pause(1.0); % correctly plot the magnet layout on the figure above

arc_rot = atrotatelattice(arc,23); % rotate by N elements

figure('Name','rotated ring','Position',[985   917   560   420]); atplot(arc_rot); 
pause(1.0); % correctly plot the magnet layout on the figure above

%% selecting elements in a list
masksf = atgetcells(arc,'FamName','SF');
disp('mask of boolean')
disp(masksf)
disp('index in ring')
indsf = find(masksf)';
disp(indsf)

ring{indsf}
ring{masksf}

disp('number of SF in one arc:')
sum(masksf)
length(indsf)

%% 