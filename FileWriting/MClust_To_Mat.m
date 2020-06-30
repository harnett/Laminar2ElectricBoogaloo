function unitdata = MClust_To_Mat(fdir,toilim,rec_areas,chs,man_corr)

cf = pwd;

addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))

cd(fdir)

% get list of numbers for TT.cut/TT.nev
dcut = dir('*.cut'); cutf = {dcut.name};

% get event data to align timestamps
eventData = read_cheetah_data('Events.Nev');

% set which channels are cortical or thalamic
area = cell(1,length(cutf));

for a = 1:length(rec_areas)
    [area{chs{a}}]=deal(rec_areas{a});
end

% csc_for_ts = read_cheetah_data('CSC 1.ncs');
% ts_start = csc_for_ts.tsI(1);
% clear csc_for_ts
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
    % ts = ts - ts_start;
    
    unit_inds = unique(cut)'; unit_inds(unit_inds<=0) = [];
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

if ~isempty(toilim)
    bu=[];
    for u = 1 : length(unitdata)
        ts=unitdata(u).ts;
        ts(ts<toilim(1)) = []; ts(ts>toilim(2))=[];
        ts = ts - toilim(1);
        unitdata(u).ts = ts;
        if isempty(ts)
            bu = [bu u];
        end
    end
    if ~isempty(bu)
        unitdata(bu) = [];
    end
end

if ~isempty(man_corr)
    for u = 1 : length(unitdata)
        unitdata(u).ts = unitdata(u).ts + man_corr;
    end
end

% [p,~] = numSubplots(length(unitdata));
% 
% for k = 1 : length(unitdata)
%     subplot(p(1),p(2),k)
%     [~,m] = max(nanmean(abs(unitdata(k).waveform_mean),2));
%     plot(unitdata(k).waveform_mean(m,:))
% end
% 
% bu = input('any bad waveforms?');
% unitdata(bu) = [];

%go back to starting directory
cd(cf)

end