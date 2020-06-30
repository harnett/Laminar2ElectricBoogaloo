function [sfrq,fd] = state_freq(lfp,nCh,states,winlen,sdir)
%winlen in secons
%  states(1).t = time_NREM; states(2).t = time_REM; states(3).t = time_Wake;


if isempty(nCh)
    nCh = 32;
end

for s = 1 : 3
    gs=time_STATE2gs(states(s).t);
    lfp2 = contgs2seg(lfp,winlen,gs);
    % find power spectra
    cfg=[]; cfg.method='mtmfft'; cfg.output='pow'; cfg.taper='dpss'; cfg.tapsmofrq=.2; cfg.foilim=[.2 500]; cfg.keeptrials='yes'; frq=ft_freqanalysis(cfg,lfp2);
    % find normalized freq-depth map
    
    sfrq{s,1} = frq; 
    fd{s,1} = fdnorm(frq);
    % find bi (32 - ch) power spectra
    lfpbi=LFP_ChanDownsamp_Mean(lfp2,nCh);
    for k = 1 : length(lfpbi.trial)
    lfpbi.trial{k}(1:(end-1),:) = diff(lfpbi.trial{k});
    end
    cfg=[]; cfg.channel=lfpbi.label(1:(end-1)); lfpbi=ft_preprocessing(cfg,lfpbi);
    cfg=[]; cfg.method='mtmfft'; cfg.output='pow'; cfg.taper='dpss'; cfg.tapsmofrq=.2; cfg.foilim=[.2 500]; cfg.keeptrials='yes'; frq=ft_freqanalysis(cfg,lfpbi);
    sfrq{s,2} = frq; 
    fd{s,2} = fdnorm(frq);    % find bi (32 - ch) normalized freq-depth map
    
    % find csd (30 - ch) power spectra
    csd = lfpbi;
    for k = 1 : length(lfp2.trial)
        csd.trial{k}(2:(end-1),:)=pg2csd_h3lam(lfpbi.trial{k});
    end
    cfg=[]; cfg.channel=csd.label(2:(end-1)); csd=ft_preprocessing(cfg,csd);
    cfg=[]; cfg.method='mtmfft'; cfg.output='pow'; cfg.taper='dpss'; cfg.tapsmofrq=.2; cfg.foilim=[.2 500]; cfg.keeptrials='yes'; frq=ft_freqanalysis(cfg,csd);
    sfrq{s,3} = frq; 
    fd{s,3} = fdnorm(frq);    % find csd (30 - ch) normalized freq-depth map

end

fq_ax = frq.freq;

if ~isempty(sdir)
if ~exist([sdir '/analysis_out'], 'dir')
    mkdir([sdir '/analysis_out'])
else
    cd([sdir '/analysis_out'])
end
save('pwrspectra.mat','fq_ax','sfrq','fd','-v7.3')
end

end