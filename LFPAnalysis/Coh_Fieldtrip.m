function [coh] = Coh_Fieldtrip(dat,epoch_len,foilim,segs)
fs = 1./(dat.time{1}(2)-dat.time{1}(1));
if ~isempty(epoch_len)
    cfg=[]; cfg.length=epoch_len; dat=ft_redefinetrial(cfg,dat);
end
if ~isempty(segs)
    cfg=[]; cfg.trials=segs; dat=ft_preprocessing(cfg,dat);
end
cfg=[]; cfg.method='mtmfft'; cfg.tapsmofrq=1./(length(dat.trial{1})./fs);
cfg.output='fourier'; 
cfg.foilim=foilim; frq=ft_freqanalysis(cfg,dat);
cfg=[]; cfg.method='coh'; cfg.complex='complex'; 
coh=ft_connectivityanalysis(cfg,frq);
end
