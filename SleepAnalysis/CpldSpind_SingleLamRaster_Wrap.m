clear

addpath(genpath('C:\Users\Loomis\Documents\Packages\CircStat2012a'))
cd C:\Users\Loomis\Documents\HO_FO_Spindles\Laminar1_PFC

load('sess_folders'), load('sess_shifts')
sess_folders = sess_folders(3:4); sess_shifts = sess_shifts(3:4); 

win=1;
fs=1000;
refch=64;
fqs=[9 17];
maxpk=20000;

chs=[]; fsrs=[];
% for each session...
for k = 1 : length(sess_folders)
    f = ['C:\Users\Loomis\Documents\HO_FO_Spindles\Laminar1_PFC\' sess_folders{k}];
    cd(f)
    % get chs
    load('UnitData.mat')
    load('LFP_1k.mat')
    load('States.mat')
    
%     lfp = LFP_ChanDownsamp_Mean(lfp,11);
%     lfp.trial{1}(1:end-1,:) = diff(lfp.trial{1});
%     cfg=[]; cfg.channel = lfp.label(1:(end-1)); lfp = ft_preprocessing(cfg,lfp);
%     
    %bycycle_spindle_detector(f,1,0,1000)
    
    cfg=[]; cfg.channel = lfp.label(63); lfp64= ft_preprocessing(cfg,lfp);
    
    %cfg=[]; cfg.channel = lfp.label(27); lfp1= ft_preprocessing(cfg,lfp);
    
    times_all = findspindlesv5(lfp64,1000,9.5,16,time_STATE2gs(states(1).t),2.6);
    
    st = times_all(:,1:2);
    
    cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq = [.2 4]; cfg.bpinstabilityfix='reduce'; lfp64_dphs = ft_preprocessing(cfg,lfp64);
    
    cfg=[]; cfg.hilbert='angle'; lfp64_dphs = ft_preprocessing(cfg,lfp64_dphs);
    
    stm = round(mean(st,2));
    
    dphss = lfp64_dphs.trial{1}(stm);
    
    [~,cds] = sort(abs(circ_dist(dphss,circ_mean(dphss'))));
        
    ch = vertcat(unitdata(:).ch);
    % shift chs
    chs = [chs; ch+sess_shifts(k)];
    % get fsrs
    fsrs = [fsrs; vertcat(unitdata(:).fsrs)];
    
    % analysis 1
    %get spindles locked to downstate average raster
    [avglfp_c,rast_singtrial_c,rast_avgmean_c,rast_avgstd_c] = raster_aligned_to_spind(unitdata,lfp,st2gs(st(cds(1:round(.5*length(cds))),:)),win,fs,refch,fqs,maxpk);
    %get spindles not locked to downstate average raster
    [avglfp,rast_singtrial,rast_avgmean,rast_avgstd] = raster_aligned_to_spind(unitdata,lfp,st2gs(st(cds(round(.5*length(cds)):end),:)),win,fs,refch,fqs,maxpk);
    
    save('cpld_uncpld_rasters.mat','avglfp_c','rast_singtrial_c','rast_avgmean_c','rast_avgstd_c',...
        'avglfp','rast_singtrial','rast_avgmean','rast_avgstd','-v7.3')
    
end