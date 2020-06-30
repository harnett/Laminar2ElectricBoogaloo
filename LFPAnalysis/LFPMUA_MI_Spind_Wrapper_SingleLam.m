clear
% for pfc lam - dont worry about sync vs async DS
addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))

cd C:\Users\Loomis\Documents\HO_FO_Spindles\Laminar1_PFC
load('sess_folders.mat')
sess_folders = sess_folders(3:4);

nCh = 15;

%loop thru sessions
ns = nan(nCh,length(sess_folders)); nd = nan(3,length(sess_folders));

nPrm = 200;

PACaa = nan(nCh,nCh,36,length(sess_folders));
PACzaa = nan(nCh,nCh,36,nPrm,length(sess_folders));
ModIndaa = nan(nCh,nCh,length(sess_folders));
ModIndZaa = nan(nCh,nCh,length(sess_folders));

for sessf = 1 : length(sess_folders)
    cd(sess_folders{sessf})
    %detect downstates
    load('LFP_1k.mat')
    load('MUA_1k.mat')
    load('States.mat')

    lfp = LFP_ChanDownsamp_Mean(lfp,nCh+1);
    mua = LFP_ChanDownsamp_Mean(mua,nCh);
    
    lfp.trial{1}(1:(size(lfp.trial{1},1)-1),:) = diff(lfp.trial{1});
    
    cfg=[]; cfg.channel = lfp.label([1:(size(lfp.trial{1},1)-1)]); lfp = ft_preprocessing(cfg,lfp);
    
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
    
    cd C:\Users\Loomis\Documents\HO_FO_Spindles\Laminar1_PFC
    %save in histogram
    disp(sessf)
    %
end

save('SpindPACResults_SingleLam.mat','PACaa','PACzaa','ModIndaa','ModIndZaa','-v7.3')