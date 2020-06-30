x = [71 200 261 6376 86000];

[avg,trldf] = osc_avg(lfp,1,1,[8.5 16],gs,5000);
imagesc(avg.avg)
cfg=[]; cfg.trl=trldf; mua2 = ft_redefinetrial(cfg,mua);
cfg=[]; mavg=ft_timelockanalysis(cfg,mua2);
figure, imagesc(zscore(mavg.avg,[],2))

%17/20 47 32