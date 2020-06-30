function [rs,zs,pvs,angs,angsall] = spk_anghist_ecd(lfp,unitdata,fqs,gs,fs)

%SIGNIFICANCE IS TOO LOW FIND BUG!!!

addpath(genpath('C:\Users\Loomis\Documents\Packages\CircStat2012a'))
% generic function which takes unitdata and lfp, finds rayleigh and phase
% distribution for each unit / frequency of interest

%loop thru each frequency, filter, phase, append data from fieldtrip2mat
phsdat=[];

%get ecd
lfp.trial{1}(1,:) = lfp.trial{1}(1,:) - lfp.trial{1}(end,:);
cfg=[]; cfg.channel = lfp.label(1); lfp=ft_preprocessing(cfg,lfp);
lfp.label{length(lfp.label)+1} = 'u1';
%interpolate 
bs = 1 : length(lfp.trial{1}); bs(gs)=[];
for k = 1 : length(unitdata)
    
    ts = unitdata(k).ts; ts = round(ts.*fs); ts = intersect(ts,gs);
    
    spk(1).time = unitdata(k).ts;
    
    dn = binspikes(spk,fs); dn = dn'; dn(dn==2)=1;

    dn = [dn zeros(1,length(lfp.trial{1})-length(dn))];  dn(bs)=0;
    
    lfp.trial{1}(2,:) = dn;
    
    cfg=[]; cfg.method='linear'; cfg.interptoi=.01; cfg.spikechannel = 'u1'; cfg.channel=lfp.label(1); lfp = ft_spiketriggeredinterpolation(cfg,lfp);

end

cfg=[]; cfg.channel = lfp.label(1); lfp=ft_preprocessing(cfg,lfp);

for k = 1 : size(fqs,1)

    cfg=[]; cfg.bpfilter='yes'; cfg.bpinstabilityfix='reduce'; cfg.bpfreq=[fqs(k,1) fqs(k,2)]; spindle = ft_preprocessing(cfg,lfp);
    cfg=[]; cfg.hilbert='angle'; tmp = ft_preprocessing(cfg,spindle);

    phsdat = cat(1,phsdat,tmp.trial{1});

    disp(['done with frequency ' num2str(k) ' out of ' num2str(size(fqs,1))])

end

rs = nan(size(fqs,1),length(unitdata));
zs = nan(size(fqs,1),length(unitdata));
pvs = nan(size(fqs,1),length(unitdata));
angs = nan(size(fqs,1),length(unitdata));

% loop thru each unit
for k = 1 : length(unitdata)
    
    ts=unitdata(k).ts; ts = round(ts.*fs); ts = intersect(ts,gs);
    
    % get matrix which only has phase across channels at spike times
    % (chsxnspikes)

    % get r-value
    r = abs(mean(exp(1i.*phsdat(:,ts)),2));
    angs = angle(mean(exp(1i.*phsdat(:,ts)),2));    
    % apply z / pvalue transforms
     
    n = length(ts);
    
    R = n * r;

    z = R.^2./n;

    pval = exp(sqrt(1+4*n+4*(n^2-R.^2))-(1+2*n));

    % save in struct (nunits long)
    rs(:,k) = squeeze(r); zs(:,k) = squeeze(z); pvs(:,k) = squeeze(pval);
    angsall(k).ang = squeeze(phsdat(:,ts));
    
    disp(['done with unit ' num2str(k) ' out of ' num2str(length(unitdata))])
    
end

end