cfg=[]; cfg.bpfilter='yes'; cfg.bpinstabilityfix='reduce'; cfg.bpfreq=[.5 4]; delta = ft_preprocessing(cfg,data);
cfg=[]; cfg.hilbert='abs'; delta = ft_preprocessing(cfg,delta);
plot(data.time{1}, smooth(mean(zscore(delta.trial{1},[],2)),1000))