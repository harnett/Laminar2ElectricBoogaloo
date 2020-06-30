function data = MUA_Writer_Mapped_v2(fdir,ds,chs,toilim,fs,csc_to_phys)

%converts .CSCs into a fieldtrip format data structure with LFPs

currentfolder = pwd;

addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))

%addpath(genpath('C:\Users\Loomis\Documents\Packages\NPMK-4.5.3.0\NPMK'))
cd(fdir)

dncs = dir('*.ncs'); ncsf = {dncs.name};

%resort ncsf so it's in correct channel order

num = [];

for tetr = 1 : length(ncsf)
    [~,tetrf,~] = fileparts(ncsf{tetr});
    num = [num str2double( tetrf( regexp( tetrf,'\d') ) )];
end

[~,srt] = sort(num); ncsf = ncsf(srt); clear num

ncsf = ncsf(csc_to_phys);

%select which channels we're loading
if isempty(chs)
    chs = 1 : length(ncsf);
end

% data=[];

% d = [];

lbls={};

cfg=[];
cfg.dataset=ncsf{chs(1)};
sing_chan=ft_preprocessing(cfg);

cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq = [300 3000]; cfg.bpinstabilityfix='reduce'; sing_chan = ft_preprocessing(cfg,sing_chan);
cfg=[]; cfg.hilbert='abs'; sing_chan = ft_preprocessing(cfg,sing_chan);
    
if ~isempty(ds) % check if we're downsampling...
    cfg=[];
    cfg.resamplefs=ds;
    sing_chan = ft_resampledata(cfg,sing_chan);
end
    
if ~isempty(toilim)
    cfg=[]; cfg.toilim=toilim; sing_chan = ft_redefinetrial(cfg,sing_chan);
end

data = sing_chan;
data.time{1} = (1/fs):(1/fs):(length(data.trial{1})/fs);
data.sampleinfo = [1 length(data.trial{1})];

d = nan(length(chs),size(sing_chan.trial{1},2));

ncsf = ncsf(chs);

chs = 1 : length(chs);

parfor tetr = chs
    
    cfg=[];
    cfg.dataset=ncsf{tetr};
    
    sing_chan=ft_preprocessing(cfg);
    
    cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq = [300 3000]; cfg.bpinstabilityfix='reduce'; sing_chan = ft_preprocessing(cfg,sing_chan);
    cfg=[]; cfg.hilbert='abs'; sing_chan = ft_preprocessing(cfg,sing_chan);
%     if ~isempty(samp_lim)
%         sing_chan.time{1}=sing_chan.time{1}(samp_lim(1):samp_lim(2));
%         sing_chan.sampleinfo = [1 length(samp_lim(1):samp_lim(2))];
%         sing_chan.trial{1}=sing_chan.trial{1}(samp_lim(1):samp_lim(2));
%     end
    
    if ~isempty(ds) % check if we're downsampling...
        cfg=[];
        cfg.resamplefs=ds;
        sing_chan = ft_resampledata(cfg,sing_chan);
    end
    
    if ~isempty(toilim)
        cfg=[]; cfg.toilim=toilim; sing_chan = ft_redefinetrial(cfg,sing_chan);
    end
    
    [~,tetrf,~] = fileparts(ncsf{tetr});
    tnum = ( tetrf( regexp( tetrf,'\d') ) );
    
    sing_chan.label{1} = ['CSC ' tnum];
    
    lbls{tetr} = sing_chan.label{1};
    
    if (length(d(tetr,:))) ~= (length(sing_chan.trial{1}))
    	sing_chan.trial{1} = [sing_chan.trial{1} 0];
    end
    
    d(tetr,:) = sing_chan.trial{1};
    
    %d = [d; sing_chan.trial{1}];
    
%     if isempty(data)
%         data=sing_chan; 
%     end
    
    %clear sing_chan
    
    disp(tetr)
end

data.label = lbls;
data.trial{1} = d;

cd(currentfolder)

end