function [coh,fx] = Coh_Fieldtrip_MemEfficient(dat,epoch_len,foilim,segs)
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

coh = nan(length(dat.label),length(dat.label),length(frq.freq));

for k = 1 : (length(dat.label) - 1)
    cc = cell(length( (k+1) : length(dat.label) ),2);
    cc(:,1) = dat.label(k);
    for kk = (k+1) : length(dat.label)
        cc(kk-k,2) = dat.label(kk);
    end
    cfg=[]; cfg.channelcmb = cc;
    cfg.method='coh'; cfg.complex='complex'; 
    cohtmp=ft_connectivityanalysis(cfg,frq);
    coh(k, (k+1) : length(dat.label) ,:) = cohtmp.cohspctrm;
    disp(k)
end
fx = coh.freq;
end
