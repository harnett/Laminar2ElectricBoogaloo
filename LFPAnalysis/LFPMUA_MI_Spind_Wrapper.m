clear
% for pfc lam - dont worry about sync vs async DS
addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))

cd C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam
sess_folders = {'C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-06-23_18-23-06','C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-06-26_11-10-11','C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-06-27_11-48-55','C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-06-28_14-09-44',...
    'C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-07-05_11-13-50',...
    'C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-07-16_15-02-42','C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-08-07_15-55-34'};

nCh = 15;

%loop thru sessions
ns = nan(nCh*2,length(sess_folders)); nd = nan(3,length(sess_folders));

nPrm = 400;

PACaa = nan(nCh*2,nCh*2,36,length(sess_folders));
PACzaa = nan(nCh*2,nCh*2,36,nPrm,length(sess_folders));
ModIndaa = nan(nCh*2,nCh*2,length(sess_folders));
ModIndZaa = nan(nCh*2,nCh*2,length(sess_folders));

for sessf = 1 : 6%length(sess_folders)
    cd(sess_folders{sessf})
    %detect downstates
    load('LFP_1k.mat')
    load('MUA_1k.mat')
    load('States.mat')

    lfp = LFP_ChanDownsamp_Mean_DualLam(lfp,nCh+1);
    mua = LFP_ChanDownsamp_Mean_DualLam(mua,nCh);
    
    lfp.trial{1}(1:(size(lfp.trial{1},1)-1),:) = diff(lfp.trial{1});
    
    cfg=[]; cfg.channel = lfp.label([1:nCh (nCh+2):(size(lfp.trial{1},1)-1)]); lfp = ft_preprocessing(cfg,lfp);
    
    %detect spindles
    times_all = findspindlesv5(lfp,1000,9.5,16,time_STATE2gs(states(1).t),3.2);
    [a,~] = hist(times_all(:,3),unique(times_all(:,3)));
    ns(:,sessf) = a';
    
    [PACa, PACza, ModInda, ModIndZa] = LFPMUA_MI_Spind(lfp,mua,nPrm,times_all);
    
    PACaa(:,:,:,sessf) = PACa;
    PACzaa(:,:,:,:,sessf) = PACza;
    ModIndaa(:,:,sessf) = ModInda;
    ModIndZaa(:,:,sessf) = ModIndZa;
    
    
    save('SpindLFPMiRes.mat','PACa', 'PACza', 'ModInda', 'ModIndZa', '-v7.3')
    
    cd C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam
    %save in histogram
    disp(sessf)
    %
end

save('SpindPACResults_DualLam.mat','PACaa','PACzaa','ModIndaa','ModIndZaa','-v7.3')