function [ppc,plv,ral,fq] = spikeLFP_continuousv2(lfp)
% takes in LFP/spike data, output spike-LFP coupling stats

% cfg           = [];
% cfg.method    = 'mtmconvol';
% cfg.foi       =  fqs;
% cfg.t_ftimwin = 5./cfg.foi; % 5 cycles per frequency
% cfg.taper     = 'hanning';
% cfg.borderspikes = 'no';
% cfg.rejectsaturation= 'yes';

cfg           = [];
cfg.method    = 'mtmfft';
cfg.foilim       =  [0 20];
cfg.timwin = [-2 2];
cfg.taper     = 'hanning';
cfg.borderspikes = 'no';
cfg.rejectsaturation= 'yes';

stsConvol     = ft_spiketriggeredspectrum(cfg, lfp);
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