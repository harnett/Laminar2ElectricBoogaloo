function [powa, anga] = Pow_PLV_dissociate(data,trldef,refch)

cfg=[]; cfg.channel = data.label(refch); data=ft_preprocessing(cfg,data);

frq = [ [.5:.25:19.5]' [1.5:.25:20.5]'];

powa = nan(trldef(1,2)-trldef(1,1)+1,size(trldef,1)); anga = powa;
for k = 1 : size(frq,1)
    % filter data in band
    cfg=[]; cfg.bpfilter='yes'; cfg.bpinstabilityfix='reduce'; cfg.bpfreq=[frq(k,1) frq(k,2)]; theta = ft_preprocessing(cfg,data);
    % get hilbert pow transform
    cfg=[]; cfg.hilbert='abs'; pow = ft_preprocessing(cfg,theta);
    % get hilbert ang transform
    cfg=[]; cfg.hilbert='angle'; ang = ft_preprocessing(cfg,theta);
    % trl epoch data
    cfg=[]; cfg.trl = trldef; pow = ft_redefinetrial(cfg,pow);
    cfg=[]; cfg.trl = trldef; ang = ft_redefinetrial(cfg,ang);
    % average the power
    pow = fieldtrip2mat_epochs(pow);
    powa(:,:,k) = squeeze(pow);
    % get the phase locking
    ang = fieldtrip2mat_epochs(ang);
    anga(:,:,k) = squeeze(ang); 
    disp(k)
end

end