function [pow,fx] = LFP_FFT_nostates(lfp,seglen,foilim)
fs = 1./(lfp.time{1}(2)-lfp.time{1}(1));
dat = contgs2seg(lfp,seglen,1:length(lfp.trial{1}));
cfg=[]; cfg.method='mtmfft'; cfg.tapsmofrq=1./(length(dat.trial{1})./fs);
cfg.output='pow'; 
cfg.foilim=foilim; frq=ft_freqanalysis(cfg,dat);
pow=frq.powspctrm; fx=frq.freq;
end