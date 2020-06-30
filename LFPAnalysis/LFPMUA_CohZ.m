function [coh,cohz,fx] = LFPMUA_CohZ(lfp,mua,gs,gseg,maxtrial)
% make sure they have same time axes
if length(lfp.trial{1})~=length(mua.trial{1})
    m = min([length(lfp.trial{1}) length(mua.trial{1})]);
    lfp.trial{1}=lfp.trial{1}(:,1:m); mua.trial{1}=mua.trial{1}(:,1:m);
end
lfp.time{1} = mua.time{1};
% concatenate
if strcmp(mua.label{1},lfp.label{1})
for k = 1 : length(mua.label)
mua.label{k} = ['m' mua.label{k}];
end
end
cfg=[]; lfpmua = ft_appenddata(cfg,lfp,mua);
if isempty(gs)
    gs = 1 : length(lfpmua.trial{1});
end
% segment within appropriate state
if isempty(gseg)
lfpmua = contgs2seg(lfpmua,5,gs);
else
cfg=[]; cfg.length=5; lfpmua=ft_redefinetrial(cfg,lfpmua);
cfg=[]; cfg.trials = gseg; lfpmua = ft_redefinetrial(cfg,lfpmua);
end
ntr = length(lfpmua.trial);
if ~isempty(maxtrial)
if maxtrial<ntr %~isempty(maxtrial) || maxtrial<ntr
    tmp = randperm(ntr);
    cfg=[]; cfg.trials=tmp(1:maxtrial); lfpmua = ft_preprocessing(cfg,lfpmua);
end
end
% get coherence
[coh,cohz,fx] = CohPrmZ_LFPMUAOnly(lfpmua,lfp.label,mua.label,100,[],[0 10],[]);
%save('LFPMUACohZRes.mat','coh','cohz')
end