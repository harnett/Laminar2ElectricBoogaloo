findspindtrghs

if isempty(lfreq)
    lfreq=9;
end
if isempty(hfreq)
    hfreq=16;
end

cfg=[]; cfg.bpfilter='yes'; cfg.bpinstabilityfix='reduce'; cfg.bpfreq=[lfreq hfreq]; lfp = ft_preprocessing(cfg,lfp);

cfg=[]; cfg.hilbert='abs'; lfp = ft_preprocessing(cfg,lfp);

[pks,pk_inds]findpeaks(-);
pksb = find(pks>=X); pk_inds(pksb)=[];

