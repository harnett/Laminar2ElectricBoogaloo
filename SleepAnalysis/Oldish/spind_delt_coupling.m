function [phsall,rsig,smu] = spind_delt_coupling(lfp,st_all)


addpath(genpath('C:\Users\Loomis\Documents\Packages\CircStat2012a'))

%delta filter

cfg=[]; cfg.bpfilter='yes'; cfg.bpinstabilityfix = 'reduce'; cfg.bpfreq = [.5 4]; delta = ft_preprocessing(cfg,lfp);

cfg=[]; cfg.hilbert='angle'; delta = ft_preprocessing(cfg,delta); dphs = delta.trial{1};

nCh = size(lfp.trial{1},1);

rsig = nan(nCh);
smu=nan(nCh);

for k = 1 : nCh
    st=st_all{k};
    st = round(mean(st,2));
    phs = dphs(:,st);
    phsall{k} = phs;
    smu(k,:)=squeeze(circ_mean(phs,[],2));
    for kk = 1 : nCh
        rsig(k,kk) = circ_r(phs(kk,:)');
    end
    disp(k)
end

% average spindles on down-state peaks
%cfg=[]; cfg.trl=[st-; pavg

% average spindles on down-state troughs
end