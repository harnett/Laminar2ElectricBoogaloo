function [coh,cohz,fx] = CohPrmZ_MemEfficient(dat,nprm,epoch_len,foilim,ge)
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
cohshff=zeros(size(coh,1),size(coh,2),size(coh,3),nprm);
frqshff=[];
parfor k=1:nprm
    frqshff=[];
    frqshff = frqshff_parfor_fun(frq);
    cohtmp = CohPrmZ_Fieldtrip_MemEfficient_Subfun(frqshff);
    cohshff(:,:,:,k)=cohtmp;
    disp(k)
end

cohmu = nanmean(abs(cohshff),4); cohstd = nanstd(abs(cohshff),[],4);

cohz = (abs(coh)-cohmu)./cohstd;
end
