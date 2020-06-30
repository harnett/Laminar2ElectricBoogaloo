function [rs,zs,pvs,angs] = spk_rtest(lfp,unitdata,fqs,gs,fs)

addpath(genpath('C:\Users\Loomis\Documents\Packages\CircStat2012a'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
% generic function which takes unitdata and lfp, finds rayleigh and phase
% distribution for each unit / frequency of interest

%loop thru each frequency, filter, phase, append data from fieldtrip2mat
phsdat=[];

nLfpCh = length(lfp.label);

lfp.label{length(lfp.label)+1} = 'u1';

lfp.time{1} = (1./fs):(1./fs):(length(lfp.trial{1})/fs);

%interpolate 
bs = 1 : length(lfp.trial{1}); bs(gs)=[];
for k = 1 : length(unitdata)
    
    %ts = unitdata(k).ts; ts = round(ts.*fs); ts = intersect(ts,gs);
    
    spk(1).time = unitdata(k).ts;
    
    dn = binspikes(spk,fs,[(1/fs) max(lfp.time{1})]); dn = dn'; dn(dn>1)=1;
    %dn = binspikes(spk,fs); dn = dn'; dn(dn>1)=1;

    dn = [dn zeros(1,length(lfp.trial{1})-length(dn))];
    
    dn(bs)=0;
    
    lfp.trial{1}((nLfpCh+k),:) = dn;
    
    lfp.label{nLfpCh+k} = ['u' num2str(k)];
    
    %cfg=[]; cfg.method='linear'; cfg.interptoi=.015; cfg.spikechannel = 'u1'; lfp = ft_spiketriggeredinterpolation(cfg,lfp);

end

dn = lfp.trial{1}(nLfpCh:end,:);

cfg=[]; cfg.channel = lfp.label(1:nLfpCh); lfp=ft_preprocessing(cfg,lfp);

for k = 1 : size(fqs,1)
cfg=[]; cfg.bpfilter='yes'; cfg.bpinstabilityfix='reduce'; cfg.bpfreq=[fqs(k,1) fqs(k,2)]; spindle = ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='angle'; tmp = ft_preprocessing(cfg,spindle);

phsdat = cat(3,phsdat,tmp.trial{1});

disp(['done with frequency ' num2str(k) ' out of ' num2str(size(fqs,1))])

end

dn = dn(:,gs); phsdat = phsdat(:,gs,:);

rs = nan(length(lfp.label),size(fqs,1),length(unitdata));
zs = nan(length(lfp.label),size(fqs,1),length(unitdata));
pvs = nan(length(lfp.label),size(fqs,1),length(unitdata));
angs = nan(length(lfp.label),size(fqs,1),length(unitdata));

% loop thru each unit
for k = 1 : length(unitdata)
    
    ts=find(dn(k,:)); tso = ts;% ts = intersect(ts,gs);
    
    %ts=unitdata(k).ts; ts = round(ts.*fs); tso = ts; ts = intersect(ts,gs);
    
    % get matrix which only has phase across channels at spike times
    % (chsxnspikes)

    % get r-value
    
    %ma = mean(exp(1i.*phsdat(:,ts,:)),2);
    
    r = abs(mean(exp(1i.*phsdat(:,ts,:)),2));
    
    ang = angle(mean(exp(1i.*phsdat(:,ts,:)),2));
    
    tz = zeros(1,max(tso)); tz(tso) = 1;
    rd=[];
    if isempty(tz)
        continue
    end
    for kk = 1 : 200
    tz = circshift(tz,randi(length(tz)));
%     if max(tss)>=size(phsdat,2)
%         disp('y')
%     end
    %tss = intersect(find(tz),gs);
    rd = cat(3,rd,abs(mean(exp(1i.*phsdat(:,tz==1,:)),2)));
    end
    % apply z / pvalue transforms
    
    z = (r - nanmean(rd,3)) ./ nanstd(rd,[],3);
    pval = erfc(z./sqrt(2))./2;
%     n = length(ts);
%     
%     R = n .* r;
% 
%     z = R.^2./n;
% 
%     pval = numel(pvs).*exp(sqrt(1+4*n+4*(n^2-R.^2))-(1+2*n));

    % save in struct (nunits long)
    rs(:,:,k) = squeeze(r); zs(:,:,k) = squeeze(z); pvs(:,:,k) = squeeze(pval);
    angs(:,:,k) = squeeze(ang);
    
    disp(['done with unit ' num2str(k) ' out of ' num2str(length(unitdata))])
    
end

end