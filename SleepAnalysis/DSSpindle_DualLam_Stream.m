clear
% for pfc lam - dont worry about sync vs async DS
addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))

% cd Y:\Milan\PFCA1_DualLam
% sess_folders = {'C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-06-23_18-23-06','Y:\Milan\PFCA1_DualLam\2019-07-05_11-13-50',...
%     'Y:\Milan\PFCA1_DualLam\2019-07-16_15-02-42','C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-08-07_15-55-34'};

cd C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam
sess_folders = {'2019-06-23_18-23-06','2019-06-26_11-10-11',...
    '2019-06-27_11-48-55','2019-06-28_14-09-44','2019-07-05_11-13-50','2019-07-16_15-02-42','2019-08-07_15-55-34'};
sess_folders = sess_folders(1:6);

spind_edge = -4000:50:4000;

nCh = 15;

h_all = nan(nCh*2,length(spind_edge)-1,length(sess_folders),2); % last dimension is downstate on each laminar
%loop thru sessions
for sessf = 1 : length(sess_folders)
    cd(sess_folders{sessf})
    %detect downstates
    load('LFP_1k.mat')
    load('MUA_1k.mat')
    load('States.mat')

    lfp = LFP_ChanDownsamp_Mean_DualLam(lfp,nCh+1);
    
    lfp.trial{1}(1:(size(lfp.trial{1},1)-1),:) = diff(lfp.trial{1});
    
    cfg=[]; cfg.channel = lfp.label([1:nCh (nCh+2):(size(lfp.trial{1},1)-1)]); lfp = ft_preprocessing(cfg,lfp);
    
    mua_mn = zscore([mean(mua.trial{1}(1:64,:)); mean(mua.trial{1}(65:end,:))],[],2);

    cfg=[]; cfg.channel = mua.label(1:2); mua2 = ft_preprocessing(cfg,mua);
    mua2.trial{1} = mua_mn;

    cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq = [.2 2.2]; cfg.bpinstabilityfix='reduce';
    mua2 = ft_preprocessing(cfg,mua2);

    [~,pk1] = findpeaks(-mua2.trial{1}(1,:)); pk1 = intersect(pk1,time_STATE2gs(states(1).t));
    [~,pk2] = findpeaks(-mua2.trial{1}(2,:)); pk2 = intersect(pk2,time_STATE2gs(states(1).t));

    %detect spindles
    times_all = findspindlesv5(lfp,1000,9.5,16,time_STATE2gs(states(1).t),3.8);
    
    %build histogram for that session, for spindle in each channel
    for k = 1 : (nCh*2)
    st=(mean(times_all(find(times_all(:,3)==k),1:2),2));

    td = pk1' - st'; %allpks{1}' - st'; 
    td = td(:); td(abs(td)>=max(spind_edge))=[];
    h = histcounts(td,spind_edge);
    h_all(k,:,sessf,1) = h;
    
    td = pk2' - st'; %allpks{1}' - st'; 
    td = td(:); td(abs(td)>=max(spind_edge))=[];
    h = histcounts(td,spind_edge);
    h_all(k,:,sessf,2) = h;
    end
    cd C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam2
    %save in histogram
    disp(sessf)
    %
end

figure
for k = 1 : 2
    subplot(1,2,k)
    imagesc(squeeze(sum(h_all(:,:,:,k),3)))
end

% rmpath(genpath('C:\Users\Loomis\Documents\Packages\SharedSpectralAnalysisforZip'));
s = squeeze(sum(h_all(:,:,:,1),3));
% imagesc(squeeze(s(:,:,1)))
figure
for k = 1 : (nCh*2)
subplot(6,6,k)
histogram('BinCounts',squeeze(s(k,:)'),'BinEdges',spind_edge)
end

s = squeeze(sum(h_all(:,:,1:3,2),3));
% imagesc(squeeze(s(:,:,1)))
figure
for k = 1 : (nCh*2)
subplot(6,5,k)
histogram('BinCounts',squeeze(s(k,:)'),'BinEdges',spind_edge)
end