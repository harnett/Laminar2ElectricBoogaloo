function KiloSingleLam(datadir)

kdirs = {'Kilo1-32','Kilo33-64'};

for k = 1 : 2
    
cd([datadir '\' kdirs{k}])
%% you need to change most of the paths in this block

addpath(genpath('C:\Users\Loomis\Documents\Packages\Kilosort2-master')) % path to kilosort folder
addpath(genpath('C:\Users\Loomis\Documents\Packages\npy-matlab-master'))

pathToYourConfigFile = 'C:\Users\Loomis\Documents\Packages\Kilosort2-master\configFiles'; % take from Github folder and put it somewhere else (together with the master_file)
if k == 1
    run(fullfile(pathToYourConfigFile, 'configFileH3_1_32.m'))
else
    run(fullfile(pathToYourConfigFile, 'configFileH3_33_64.m'))
end
rootH = [datadir '\' kdirs{k}];
ops.fproc       = fullfile(rootH, 'temp_wh.dat'); % proc file on a fast SSD
if k==1 
    ops.chanMap = fullfile(pathToYourConfigFile, 'H3_10x2D32_kilosortChanMap.mat');
elseif k==2 
    ops.chanMap = fullfile(pathToYourConfigFile, 'H3_330x2D64_kilosortChanMap.mat');
end

ops.trange = [0 Inf]; % time range to sort
ops.NchanTOT    = 32; % total number of channels in your recording

% the binary file is in this folder
rootZ = [datadir '\' kdirs{k}];

%% this block runs all the steps of the algorithm
fprintf('Looking for data inside %s \n', rootZ)

% is there a channel map file in this folder?
fs = dir(fullfile(rootZ, 'chan*.mat'));
if ~isempty(fs)
    ops.chanMap = fullfile(rootZ, fs(1).name);
end

% find the binary file
fs          = [dir(fullfile(rootZ, '*.bin')) dir(fullfile(rootZ, '*.dat'))];
ops.fbinary = fullfile(rootZ, fs(1).name);

% preprocess data to create temp_wh.dat
rez = preprocessDataSub(ops);

% time-reordering as a function of drift
rez = clusterSingleBatches(rez);
save(fullfile(rootZ, 'rez.mat'), 'rez', '-v7.3');

% main tracking and template matching algorithm
rez = learnAndSolve8b(rez);

% final merges
rez = find_merges(rez, 1);

% final splits by SVD
rez = splitAllClusters(rez, 1);

% final splits by amplitudes
rez = splitAllClusters(rez, 0);

% decide on cutoff
rez = set_cutoff(rez);

fprintf('found %d good units \n', sum(rez.good>0))

% write to Phy
fprintf('Saving results to Phy  \n')
rezToPhy(rez, rootZ);

%% if you want to save the results to a Matlab file... 

% discard features in final rez file (too slow to save)
rez.cProj = [];
rez.cProjPC = [];

% save final results as rez2
fprintf('Saving final results in rez2  \n')
fname = fullfile(rootZ, 'rez2.mat');
save(fname, 'rez', '-v7.3');
end

