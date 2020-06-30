function [ppc,plv,ral,fq] = spikeLFP_continuous(lfp,unitdata,fqs,states)
% takes in LFP/spike data, output spike-LFP coupling stats

data = LFP_Unit_View(lfp,unitdata,0);
data = contgs2seg(data,10,time_STATE2gs(states(1).t));

cfg           = [];
%cfg.method    = 'mtmconvol';
cfg.foi       =  fqs;
cfg.t_ftimwin = 5./cfg.foi; % 5 cycles per frequency
cfg.taper     = 'hanning';
cfg.borderspikes = 'no';
stsConvol     = ft_spiketriggeredspectrum(cfg, data);
fq = stsConvol.freq;
ppc=[]; ral=[]; plv=[];
for k = 1:length(stsConvol.label)

  % compute the statistics on the phases
  cfg               = [];
  cfg.method        = 'ppc0'; % compute the Pairwise Phase Consistency
  cfg.spikechannel  = stsConvol.label{k};
  cfg.channel       = 'all';%stsConvol.lfplabel(chan); % selected LFP channels
  statSts           = ft_spiketriggeredspectrum_stat(cfg,stsConvol);
  ppc = cat(3,ppc,statSts.ppc0);
  
  cfg.method        = 'ral'; % compute the Pairwise Phase Consistency
  statSts           = ft_spiketriggeredspectrum_stat(cfg,stsConvol);
  
  ral = cat(3,ral,statSts.ral);
  
  cfg.method        = 'plv'; % compute the Pairwise Phase Consistency
  statSts           = ft_spiketriggeredspectrum_stat(cfg,stsConvol);
  
  plv = cat(3,plv,statSts.plv);
end