function [sig] = PermStatCoh(frq,trgts,fill,nPerms)
% permutation cluster testing on 'cube' (multiple 2d matrices) with
% indices. test if subset of said 2d matrices are significantly different
% in blobs from 3d matrix
%% stats for time-domain

numTrgts=length(trgts);
numFill=length(fill);
TrgtFill= 1:(numTrgts+numFill);
numTr=length(TrgtFill);


    cfg=[]; cfg.method='coh'; cfg.complex='complex'; cfg.trials=trgts; coh=ft_connectivityanalysis(cfg,frq);
    crt=abs(coh.cohspctrm); crt=crt.^2;
    
    cfg=[]; cfg.method='coh'; cfg.complex='complex'; cfg.trials=fill; coh=ft_connectivityanalysis(cfg,frq);
    cft=abs(coh.cohspctrm); cft=cft.^2;

for k=1:nPerms
    TrgtPm=randperm(numTr);
    TrgtPm=TrgtPm(1:numTrgts);
    FillPm=1:numTr; FillPm(TrgtPm)=[];
    trials=TrgtFill(FillPm);
    
    %% calculate 'target' coherence
    cfg=[]; cfg.method='coh'; cfg.complex='complex'; cfg.trials=TrgtPm; coh=ft_connectivityanalysis(cfg,frq);
    cr=abs(coh.cohspctrm); cr=cr.^2;

    %% calculate 'filler' coherence
    cfg=[]; cfg.method='coh'; cfg.complex='complex'; cfg.trials=FillPm; coh=ft_connectivityanalysis(cfg,frq);
    cf=abs(coh.cohspctrm); cf=cf.^2;
    %% find difference, save it
    if k==1
        pmdiff=cr-cf;
    else
        pmdiff=cat(4,pmdiff,cr-cf);
    end
%     pmdiff(:,:,k)=trgt-filler;
    disp(k)
end

imu=(nanmean(pmdiff,4));
istd=(nanstd(pmdiff,[],4));

sig=((crt-cft)-imu)./istd;
