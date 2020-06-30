function lfphgp = LFPHGP_Concat_Lam(lfp)
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[70 190]; hgp=ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='abs'; hgp=ft_preprocessing(cfg,hgp);
for k = 1 : length(hgp.label)
hgp.label{k} = ['h' hgp.label{k}];
end
cfg=[]; lfphgp = ft_appenddata(cfg,lfp,hgp);
end