function [sfrq,fd,fq_ax] = state_freqv2(lfp,states,winlen)
%winlen in secons
%  states(1).t = time_NREM; states(2).t = time_REM; states(3).t = time_Wake;

for s = 1 : 3
    gs=time_STATE2gs(states(s).t);
    lfp2 = contgs2seg(lfp,winlen,gs);
    % find power spectra
    cfg=[]; cfg.method='mtmfft'; cfg.output='pow'; cfg.taper='dpss'; cfg.tapsmofrq=.2; cfg.foilim=[.2 500]; cfg.keeptrials='no'; frq=ft_freqanalysis(cfg,lfp2);
    % find normalized freq-depth map
    
    sfrq(:,:,s) = frq.powspctrm; 
    fd(:,:,s) = fdnorm(frq);

end

fq_ax = frq.freq;

end