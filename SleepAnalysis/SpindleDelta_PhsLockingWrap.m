clear
% for pfc lam - dont worry about sync vs async DS
addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))

cd C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam
% sess_folders = {'C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-06-23_18-23-06','Y:\Milan\PFCA1_DualLam\2019-07-05_11-13-50',...
%     'Y:\Milan\PFCA1_DualLam\2019-07-16_15-02-42','C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-08-07_15-55-34'};

sess_folders = {'2019-06-23_18-23-06','2019-06-26_11-10-11',...
    '2019-06-27_11-48-55','2019-06-28_14-09-44','2019-07-05_11-13-50','2019-07-16_15-02-42','2019-08-07_15-55-34'};

sess_folders = sess_folders(1:6);

% sess_folders = sess_folders(1:2);

nCh = 15;

rsiga = nan(nCh*2,nCh*2,length(sess_folders)); % last dimension is downstate on each laminar
smua = rsiga;
za = rsiga;
pvala = rsiga;
rsigam = rsiga; smuam = rsiga; zam = rsiga; pvalam=rsiga;
%loop thru sessions
for sessf = 1 : length(sess_folders)
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
    times_all = findspindlesv5(lfp,1000,9.5,16,time_STATE2gs(states(1).t),3.8);
    
    %build histogram for that session, for spindle in each channel
    [phsall,rsig,smu,z,pval] = spind_delt_couplingv2(lfp,times_all);
    [phsallm,rsigm,smum,zm,pvalm] = spind_MUAdelt_couplingv2(lfp,mua,times_all);
    
    rsiga(:,:,sessf) = rsig;
    smua(:,:,sessf) = smu;
    za(:,:,sessf) = z;
    pvala(:,:,sessf) = pval;
    phsalla(sessf,:) = phsall;
    
    rsigam(:,:,sessf) = rsigm;
    smuam(:,:,sessf) = smum;
    zam(:,:,sessf) = zm;
    pvalam(:,:,sessf) = pvalm;
    phsallam(sessf,:) = phsallm;
    
    cd C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam
    %save in histogram
    disp(sessf)
    %
end

save('SpindDeltOut.mat','rsiga','smua','za','pvala','phsalla','rsigam','smuam','zam','pvalam','phsallam','-v7.3')