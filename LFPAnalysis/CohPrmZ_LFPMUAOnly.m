function [coh,cohz,fx] = CohPrmZ_LFPMUAOnly(dat,lfplbl,mualbl,nprm,epoch_len,foilim,ge)
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

cc = cell(length(lfplbl).*length(mualbl),2);

cci = 1;
for k = 1 : length(lfplbl)
    for kk = 1 : length(mualbl)
        cc(cci,1) = lfplbl(k); cc(cci,2) = mualbl(kk);
        cci = cci + 1;
    end
end

[coh] = CohPrmZ_LFPMUAONly_Subfun(frq,cc,lfplbl,mualbl);
fx = frq.freq;
cohshff=zeros(size(coh,1),size(coh,2),size(coh,3),nprm);
parfor k=1:nprm
    %frqshff=[];
    frqshff = frqshff_parfor_fun(frq);
    [cohtmp] = CohPrmZ_LFPMUAONly_Subfun(frqshff,cc,lfplbl,mualbl);
    cohshff(:,:,:,k)=cohtmp;
    disp(k)
end

cohmu = nanmean(abs(cohshff),4); cohstd = nanstd(abs(cohshff),[],4);

cohz = (abs(coh)-cohmu)./cohstd;
end
