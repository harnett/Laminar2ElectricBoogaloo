function coh = LFPMUA_Coh(lfp,mua,gs)
% make sure they have same time axes
if length(lfp.trial{1})~=length(mua.trial{1})
    m = min([length(lfp.trial{1}) length(mua.trial{1})]);
    lfp.trial{1}=lfp.trial{1}(:,1:m); mua.trial{1}=mua.trial{1}(:,1:m);
end
lfp.time{1} = mua.time{1};
% concatenate
lfpmua = LFPMUA_Concat_Lam(lfp,mua);
% segment within appropriate state
lfpmua = contgs2seg(lfpmua,2.5,gs);
% get coherence
coh = Coh_Fieldtrip(lfpmua,[],[0 50],[]);
save('LFPMUACohRes.mat','coh')
end