function itpc = itpc_across_freqs(data,trl,fqs)

itpc = zeros(length(data.label),trl(1,2)-trl(1,1)+1,size(fqs,1));

for k = 1 : size(fqs,1)
    
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[fqs(k,1) fqs(k,2)];
cfg.bpinstabilityfix='reduce'; data2=ft_preprocessing(cfg,data);
cfg=[]; cfg.hilbert='angle';  data2=ft_preprocessing(cfg,data2);
cfg=[]; cfg.trl = trl; data2 = ft_redefinetrial(cfg,data2);

x = fieldtrip2mat_epochs(data2);

itpc(:,:,k) = abs(mean(exp(1i.*x),3));

end

end