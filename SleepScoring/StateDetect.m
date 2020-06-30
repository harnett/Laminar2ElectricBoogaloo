function StateDetect(f,lfp,data)
%% Detect States
%f = 'C:\Users\Loomis\Documents\HO_FO_Spindles\Laminar1_PFC\2019-05-31_12-38-33\Kilo1-32';
cd(f)
cfg=[]; 
%cfg.channel=lfp.label([2]); 
emg=ft_preprocessing(cfg,data);
cfg=[]; cfg.bpfilter='yes'; cfg.bpinstabilityfix='reduce'; cfg.bpfreq=[63 100]; emg = ft_preprocessing(cfg,emg);
%cfg=[]; cfg.bpfilter='yes'; cfg.bpinstabilityfix='reduce'; cfg.bpfreq=[70 190]; emg = ft_preprocessing(cfg,lfp);
addpath(genpath('C:\Users\Loomis\Documents\Packages\SharedSpectralAnalysisforZip'))
states = ProtoStateDetectv3( lfp.trial{1}(50,:),lfp.trial{1}(120,:),(emg.trial{1}(10,:)),1000,lfp.time{1},0,1);
save('States.mat','states')
end