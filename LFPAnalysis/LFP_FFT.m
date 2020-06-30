function [pow,powall,fx] = LFP_FFT(lfp,states,seglen)
fs = 1./(lfp.time{1}(2)-lfp.time{1}(1));
powall=[];
for s = 1 : 3
dat = contgs2seg(lfp,seglen,time_STATE2gs(states(s).t));
cfg=[]; cfg.method='mtmfft'; cfg.tapsmofrq=1./(length(dat.trial{1})./fs);
cfg.output='pow'; 
cfg.foilim=[0 400]; frq=ft_freqanalysis(cfg,dat);
pow{s}=frq.powspctrm; fx=frq.freq;
powall = [powall; pow{s}];
end
end