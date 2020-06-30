function StateDetect_UnitCombine(f)
%% Detect States
%f = 'C:\Users\Loomis\Documents\HO_FO_Spindles\Laminar1_PFC\2019-05-31_12-38-33\Kilo1-32';
cd f
load('LFP_1k.mat')
cfg=[]; cfg.channel=lfp.label([15]); emg=ft_preprocessing(cfg,lfp);
cfg=[]; cfg.bpfilter='yes'; cfg.bpinstabilityfix='reduce'; cfg.bpfreq=[70 190]; emg = ft_preprocessing(cfg,emg);
cfg=[]; cfg.bpfilter='yes'; cfg.bpinstabilityfix='reduce'; cfg.bpfreq=[70 190]; emg = ft_preprocessing(cfg,lfp);
addpath(genpath('C:\Users\Loomis\Documents\Packages\SharedSpectralAnalysisforZip'))
states = ProtoStateDetectv3( lfp.trial{1}(1,:),lfp.trial{1}(64,:),mean(emg.trial{1}),1000,lfp.time{1},0,1);
save('States.mat','states')
%% Combine Units
u1 = KiloSort_To_Mat(f,{'PFC'},{[1:32]});
u2 = KiloSort_To_Mat(f,{'PFC'},{[1:32]});
unitdata = unitdata_combine_preprocess(u1,u2);
save('Unitdata.mat','unitdata')