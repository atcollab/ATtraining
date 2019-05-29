function set_my_path(rootpath)

% cancel previous path for this user in this matlab session.
restoredefaultpath; 

if nargin < 1, rootpath=pwd; end


addpath(fullfile(rootpath)); % add current folder in path

% set AT in the PATH
addpath(genpath(fullfile(rootpath,'/at-master/at-master/atmat')));
addpath(genpath(fullfile(rootpath,'/at-master/at-master/atintegrators')));
addpath(genpath(fullfile(rootpath,'/at-master/at-master/machine_data')));

end