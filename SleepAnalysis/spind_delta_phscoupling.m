function [dphs,pv,z] = spind_delta_phscoupling(data,st)
addpath(genpath('C:\Users\Loomis\Documents\Packages\CircStat2012a'))
cfg=[]; cfg.channel=data.label(1); data = ft_preprocessing(cfg,data);
st = round(mean(st(:,1:2),2));
cfg=[]; cfg.channel = data.label(1); data=ft_preprocessing(cfg,data);
cfg=[]; cfg.bpfilter='yes'; cfg.bpinstabilityfix='reduce'; cfg.bpfreq=[.5 3.5]; delta = ft_preprocessing(cfg,data);
cfg=[]; cfg.hilbert='angle'; delta = ft_preprocessing(cfg,delta);
dphs = delta.trial{1}(st);
pv=[]; z=[];
if ~isempty(dphs)
[pv, z] = circ_rtest(dphs);
end
end