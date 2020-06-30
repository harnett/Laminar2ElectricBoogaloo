function [coh,cohz,cohshf,frq] = CohPrmZ_PAC(dat,nprm,epoch_len,foilim,ampb,ge)
cci = 1;
dato = dat;
for amp = 1 : size(ampb,1)
    cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[ampb(amp,1) ampb(amp,2)]; cfg.bpinstabilityfix='reduce'; mua = ft_preprocessing(cfg,dato);
    cfg=[]; cfg.hilbert='abs'; mua = ft_preprocessing(cfg,mua);
    for k = 1 : length(mua.label)
        mua.label{k} = ['a' num2str(amp) '_' mua.label{k}];
    end
    cfg=[]; dat = ft_appenddata(cfg,dat,mua);
    for k = 1 : length(dato.label)
        for kk = 1 : length(mua.label)
            cc{cci,1} = dato.label{k}; cc{cci,2} = mua.label{kk};
            cci = cci + 1;
        end
    end
end
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
cfg=[]; cfg.method='coh'; cfg.complex='complex'; cfg.channelcmb = cc;
coh=ft_connectivityanalysis(cfg,frq);
cohshff=nan(size(coh.cohspctrm,1),size(coh.cohspctrm,2),nprm);
frqshff=[];
parfor k=1:nprm
    frqshff=[];
    frqshff = frqshff_parfor_fun(frq);
    cfg=[]; cfg.method='coh'; cfg.complex='abs'; cfg.channelcmb = cc;
    cohtmp=ft_connectivityanalysis(cfg,frqshff);
    cohshff(:,:,k)=cohtmp.cohspctrm;
    disp(k)
end

frq = coh.freq;

ca = abs(coh.cohspctrm);

cohmu = nanmean(cohshff,3); cohstd = nanstd(cohshff,[],3);

cohz_uns = (abs(coh.cohspctrm)-cohmu)./cohstd;

cohz = nan(length(dato.label),length(dato.label),size(cohz_uns,2),size(ampb,1));
coh = cohz;
cohshf = nan(length(dato.label),length(dato.label),size(cohz_uns,2),nprm,size(ampb,1));

for k = 1 : size(cohz_uns,1)
    strtmp = extractAfter(cc{k,2},'_');
    cohz(find(ismember(dato.label,cc{k,1})),find(ismember(dato.label,strtmp)),:,ceil(k/(length(dato.label).^2))) = cohz_uns(k,:);
    cohshf(find(ismember(dato.label,cc{k,1})),find(ismember(dato.label,strtmp)),:,:,ceil(k/(length(dato.label).^2))) = cohshff(k,:,:);
    coh(find(ismember(dato.label,cc{k,1})),find(ismember(dato.label,strtmp)),:,ceil(k/(length(dato.label).^2))) = ca(k,:);
end
