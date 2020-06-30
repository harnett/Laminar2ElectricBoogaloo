function [coh,cohz] = CohPrmZ(dat,nprm,epoch_len,foilim,ge)
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
cfg=[]; cfg.method='coh'; cfg.complex='complex'; 
coh=ft_connectivityanalysis(cfg,frq);
cohshff=nan(size(coh.cohspctrm,1),size(coh.cohspctrm,2),size(coh.cohspctrm,3),nprm);
frqshff=[];
parfor k=1:nprm
    frqshff=[];
    frqshff = frqshff_parfor_fun(frq);
    cfg=[]; cfg.method='coh'; cfg.complex='abs'; 
    cohtmp=ft_connectivityanalysis(cfg,frqshff);
    cohshff(:,:,:,k)=cohtmp.cohspctrm;
    disp(k)
end

cohmu = nanmean(cohshff,4); cohstd = nanstd(cohshff,[],4);

cohz = (abs(coh.cohspctrm)-cohmu)./cohstd;
end
