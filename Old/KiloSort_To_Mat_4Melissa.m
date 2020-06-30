function unitdata = KiloSort_To_Mat_4Melissa(fdir)

addpath(genpath('C:\Users\Loomis\Documents\Packages\npy-matlab-master'))

cf = pwd;

cd(fdir)

addpath(genpath('C:\Users\Loomis\Documents\Packages\spikes-master'))

spikeStruct = loadKSdir(fdir);

%[spikeAmps, spikeDepths, templateDepths, tempAmps, tempsUnW, templateDuration, waveforms] = ...
%    templatePositionsAmplitudes(spikeStruct.temps, spikeStruct.winv, spikeStruct.ycoords, spikeStruct.spikeTemplates, spikeStruct.tempScalingAmps);

gwfparams.dataDir = fdir;    % KiloSort/Phy output folder
gwfparams.fileName = spikeStruct.dat_path;         % .dat file containing the raw 
gwfparams.dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
gwfparams.nCh = spikeStruct.n_channels_dat;%length(spikeStruct.xcoords);                      % Number of channels that were streamed to disk in .dat file
gwfparams.wfWin = [-100 101];              % Number of samples before and after spiketime to include in waveform
gwfparams.nWf = 2000;                    % Number of waveforms per unit to pull out
gwfparams.spikeTimes =    round(spikeStruct.st.*spikeStruct.sample_rate); % Vector of cluster spike times (in samples) same length as .spikeClusters
gwfparams.spikeClusters = spikeStruct.clu; % Vector of cluster IDs (Phy nomenclature)   same length as .spikeTimes
wf = getWaveForms(gwfparams);

ts = spikeStruct.st;%in seconds (at least for tupac)
uvars = squeeze(nanvar(wf.waveForms,[],2));

% for every tetrode...
for u = 1 : length(spikeStruct.cids)
    clust = spikeStruct.cids(u);
    % get sample indices corresponding to that unit
    ts_samp = find(spikeStruct.clu == clust);
    % save timestamps of each unit
    unitdata(u).ts = ts(ts_samp);
    % save channel of unit
    [~,unitdata(u).ch] = max(max(abs(squeeze(wf.waveFormsMean(u,:,:))),[],2));
    % save whether thalamic or cortical
    % save waveform mean and variance on each trode
    unitdata(u).waveform_mean = squeeze(wf.waveFormsMean(u,:,:));
    unitdata(u).waveform_var = squeeze(uvars(u,:,:));
    unitdata(u).quality = spikeStruct.cgs(u);
    unitdata(u).orig_unit = u;
end

%go back to starting directory
cd(cf)

end