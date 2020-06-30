function [coh,fx] = Coh_MemEfficient(dat,epoch_len,foilim,ge)
fs = 1./(dat.time{1}(2)-dat.time{1}(1));
if ~isempty(epoch_len)
    cfg=[]; cfg.length=epoch_len; dat=ft_redefinetrial(cfg,dat);
end
if ~isempty(ge)
    cfg=[]; cfg.trials = ge; dat = ft_redefinetrial(cfg,dat);
end
cfg=[]; cfg.method='mtmfft'; cfg.tapsmofrq=1./(length(dat.trial{1})./fs);
cfg.output='fourier'; 
cfg.foilim=foilim; frq=ft_freqanalysis(cfg,dat);
[coh] = CohPrmZ_Fieldtrip_MemEfficient_Subfun(frq);
fx = frq.freq;
end