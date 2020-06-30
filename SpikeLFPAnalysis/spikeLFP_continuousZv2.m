function [ppc,plv,ral,ppcz,plvz,ralz,fq] = spikeLFP_continuousZv2(lfp,unitdata,gs,nPrm)

lfp = LFP_Unit_View(lfp,unitdata,0);

if isempty(gs)
    gs = 1 : length(lfp.trial{1});
end

% lfp = contgs2seg(lfp,6,gs);

% if ~isempty(maxTrl)
% if length(lfp.trial) > maxTrl
%     tmp = randperm(length(lfp.trial));
%     cfg=[]; cfg.trials = tmp(1:maxTrl); lfp = ft_redefinetrial(cfg,lfp);
% end
% end

[ppc,plv,ral,fq] = spikeLFP_continuousv2(lfp);
ppcz = nan(size(ppc,1),size(ppc,2),size(ppc,3),nPrm);
plvz = ppcz; ralz = ppcz;
parfor k = 1 : nPrm
    lfp2 = lfp;
    for kk = 1 : size(lfp.trial{1},1)
    lfp2.trial{1}(kk,:) = circshift(lfp2.trial{1}(kk,:),randperm(length(lfp.trial{1}),1))
    end
    [ppctmp,plvtmp,raltmp,~] = spikeLFP_continuousv2(lfp2);
    
    ppcz(:,:,:,k) = ppctmp;
    plvz(:,:,:,k) = plvtmp;
    ralz(:,:,:,k) = raltmp;
    disp(['Perm' ' ' num2str(k)])
end

ppcz = squeeze ( (ppc - squeeze(nanmean(ppcz,4))) ./ nanstd(ppcz,[],4));
plvz = squeeze ( (plv - squeeze(nanmean(plvz,4))) ./ nanstd(plvz,[],4));
ralz = squeeze ( (ral - squeeze(nanmean(ralz,4))) ./ nanstd(ralz,[],4));
