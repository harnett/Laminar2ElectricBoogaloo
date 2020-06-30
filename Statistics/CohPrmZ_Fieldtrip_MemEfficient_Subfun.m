function [coh] = CohPrmZ_Fieldtrip_MemEfficient_Subfun(frq)

coh = zeros(length(frq.label),length(frq.label),length(frq.freq));

for k = 1 : (length(frq.label) - 1)
    cc = cell(length( (k+1) : length(frq.label) ),2);
    cc(:,1) = frq.label(k);
    for kk = (k+1) : length(frq.label)
        cc(kk-k,2) = frq.label(kk);
    end
    cfg=[]; cfg.channelcmb = cc;
    cfg.method='coh'; cfg.complex='complex'; 
    cohtmp=ft_connectivityanalysis(cfg,frq);
    coh(k, (k+1) : length(frq.label) ,:) = cohtmp.cohspctrm;
end
coh = nansum(cat(4,coh,permute(coh,[2 1 3])),4);
end
