function [phsall,rsig,smu,z,pval] = spind_MUAdelt_couplingv2(lfp,mua,times_all)


addpath(genpath('C:\Users\Loomis\Documents\Packages\CircStat2012a'))

%delta filter
% REPLACE
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq = [.2 4]; cfg.bpinstabilityfix='reduce';
mua = ft_preprocessing(cfg,mua);

cfg=[]; cfg.hilbert='angle'; delta = ft_preprocessing(cfg,mua); dphs = delta.trial{1};

nCh = size(lfp.trial{1},1);

rsig = nan(nCh);
smu=nan(nCh);
z=nan(nCh);
for k = 1 : nCh
    %get spindle times, onset or mean
    st=times_all(find(times_all(:,3)==k),1);
    tz=zeros(1,length(dphs(1,:))); tz(st) = 1; % for shuffling later
    %st = round(mean(st,2));
    %get SO phase across all spindles/channels
    phs = dphs(:,st);
    %this is weird think about it
    phsall{k} = phs;
    %get the mean SO phase across all channels for that spindle channel
    smu(k,:)=squeeze(circ_mean(phs,[],2));
    
    rsig(k,:) = abs(mean(exp(1i.*phs),2));
    
    rd=nan(size(dphs,1),200);
    for kk = 1 : 200
    tz = circshift(tz,randi(length(tz)));
%     if max(tss)>=size(phsdat,2)
%         disp('y')
%     end
    %tss = intersect(find(tz),gs);
    rd(:,kk) = abs(mean(exp(1i.*dphs(:,tz==1)),2));
    end
    % apply z / pvalue transforms
    
    z(k,:) = (rsig(k,:) - nanmean(rd,2)') ./ nanstd(rd,[],2)';
    
    disp(k)
end

pval = erfc(z./sqrt(2))./2;

% average spindles on down-state peaks
%cfg=[]; cfg.trl=[st-; pavg

% average spindles on down-state troughs
end