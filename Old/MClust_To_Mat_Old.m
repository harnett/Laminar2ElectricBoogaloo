% CHANGE SO THAT IT ITERATES THRU ONLY TETRODES FOR WHICH A .CUT EXISTS!!!!
clear
addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))

fdir = '\\18.93.6.50\public\Milan\MGBA1\37';

cd(fdir)

% get list of numbers for TT.cut/TT.nev
dcut = dir('*.cut'); cutf = {dcut.name};

% get event data to align timestamps
eventData = read_cheetah_data('Events.Nev');

% set which channels are cortical or thalamic
area = cell(1,length(cutf));

[area{[1:10 13:24]}]=deal('MGB');
[area{[11:22]}]=deal('A1');

% for every tetrode...
ind = 1;
for tetr = 1 : length(cutf)
    % load .ntt file (timestamps)
    % load .cut file (cluster indices)
    cut = load(cutf{tetr});
    [~,tetrf,~] = fileparts(cutf{tetr});
    tetrf = [tetrf '.ntt'];
    ntt = read_cheetah_data(tetrf);
    ts = double(ntt.ts);%in seconds (at least for tupac)
    
    tnum = str2num( tetrf( regexp( tetrf,'\d') ) );
    % align timestamps to data start via events .nev file
    ts = ts - eventData.ts(1);
    unit_inds = unique(cut)'; unit_inds(unit_inds==0) = [];
    % loop thru units
    for u = unit_inds
        % get sample indices corresponding to that unit
        ts_samp = find(cut == u);
        % save timestamps of each unit
        unitdata(ind).ts = ts(ts_samp);
        % save tetrode of unit
        unitdata(ind).tetrode = tnum;
        % save whether thalamic or cortical
        unitdata(ind).area = area{tnum};
        % save waveform mean and variance on each trode
        unitdata(ind).waveform_mean = mean(ntt.waveforms(:,:,ts_samp),3);
        unitdata(ind).waveform_var = var(ntt.waveforms(:,:,ts_samp),[],3);
        %update unit ind
        ind = ind + 1;
    end
end