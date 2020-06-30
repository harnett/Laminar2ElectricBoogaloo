function data = MUA_Writer_Mapped(fdir,ds,chs,toilim,csc_to_phys)

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

bi=zeros(1,length(ncsf)); 
for k = 1 : length(ncsf)
if ~strcmp(ncsf{k}(1:3),'CSC')
bi(k) = 1;
end
end
ncsf(find(bi)) = [];

%resort ncsf so it's in correct channel order

num = [];

for tetr = 1 : length(ncsf)
    [~,tetrf,~] = fileparts(ncsf{tetr});
    num = [num str2double( tetrf( regexp( tetrf,'\d') ) )];
end

[~,srt] = sort(num); ncsf = ncsf(srt); clear num

if isempty(csc_to_phys)
    csc_to_phys = 1:length(ncsf);
end

ncsf = ncsf(csc_to_phys);

%select which channels we're loading
if isempty(chs)
    chs = 1 : length(ncsf);
end

data=[];

for tetr = chs
    cfg=[];
    cfg.dataset=ncsf{tetr};
    sing_chan=ft_preprocessing(cfg);
    
    %filter and take hilbert transform
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
    
    [~,tetrf,~] = fileparts(ncsf{tetr});
    tnum = ( tetrf( regexp( tetrf,'\d') ) );
    
    sing_chan.label{1} = ['CSC ' tnum];
    
    if isempty(data)
        data=sing_chan; clear sing_chan
    else
        cfg=[];
        if ~isequal(data.time{1},sing_chan.time{1})
            disp('warning: time vectors are different')
            sing_chan.time{1} = data.time{1};
        end
        data=ft_appenddata(cfg,data,sing_chan);
    end
    disp(tetr)
end

cd(currentfolder)

end