function [coh, cohz] = DualLam_LFPg_LFPMUACohZ(lfp,mua,gs,nch,maxtrial)
%get LFPg and mean MUA
lfp = LFP_ChanDownsamp_Mean_DualLam(lfp,nch);
mua = LFP_ChanDownsamp_Mean_DualLam(mua,nch);
lfp.trial{1}(1:(end-1),:) = diff(lfp.trial{1});
cfg=[]; cfg.channel=lfp.label([1:(nch-1) (nch+1):(end-1)]); lfp = ft_preprocessing(cfg,lfp);
cfg=[]; cfg.channel=mua.label([1:(nch-1) (nch+1):(end-1)]); mua = ft_preprocessing(cfg,mua);
[coh,cohz] = LFPMUA_CohZ(lfp,mua,gs,maxtrial);
end