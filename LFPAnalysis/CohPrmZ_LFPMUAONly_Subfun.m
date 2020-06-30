function [coh] = CohPrmZ_LFPMUAONly_Subfun(frq,cc,lfplbl,mualbl)

cfg=[]; cfg.channelcmb = cc;
cfg.method='coh'; cfg.complex='complex'; 
cohtmp=ft_connectivityanalysis(cfg,frq);
coh = reshape(cohtmp.cohspctrm,length(lfplbl),length(mualbl),length(frq.freq));

end
