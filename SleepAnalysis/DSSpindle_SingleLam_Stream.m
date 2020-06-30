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

spind_edge = -4000:50:4000;

nCh = 15;

h_all = nan(nCh,length(spind_edge)-1,length(sess_folders)); % last dimension is downstate on each laminar
ns = nan(nCh,length(sess_folders));
%loop thru sessions
for sessf = 1 : length(sess_folders)
    cd(sess_folders{sessf})
    %detect downstates
    load('LFP_1k.mat')
    load('MUA_1k.mat')
    load('States.mat')

    lfp = LFP_ChanDownsamp_Mean(lfp,nCh+1);
    
    lfp.trial{1}(1:(size(lfp.trial{1},1)-1),:) = diff(lfp.trial{1});
    
    cfg=[]; cfg.channel = lfp.label(1:nCh); lfp = ft_preprocessing(cfg,lfp);
    
    mua_mn = zscore([mean(mua.trial{1}(1:64,:))],[],2);

    cfg=[]; cfg.channel = mua.label(1); mua2 = ft_preprocessing(cfg,mua);
    mua2.trial{1} = mua_mn;

    cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq = [.2 2.2]; cfg.bpinstabilityfix='reduce';
    mua2 = ft_preprocessing(cfg,mua2);

    [~,pk1] = findpeaks(-mua2.trial{1}(1,:)); pk1 = intersect(pk1,time_STATE2gs(states(1).t));
    
    %detect spindles
    times_all = findspindlesv5(lfp,1000,9.5,16,time_STATE2gs(states(1).t),2.6);
    
    [a,~] = hist(times_all(:,3),unique(times_all(:,3)));
    
    ns(:,sessf) = a';
    
    %build histogram for that session, for spindle in each channel
    for k = 1 : (nCh)
    st=(mean(times_all(find(times_all(:,3)==k),1:2),2));

    td = pk1' - st'; %allpks{1}' - st'; 
    td = td(:); td(abs(td)>=max(spind_edge))=[];
    h = histcounts(td,spind_edge);
    h_all(k,:,sessf) = h;
    
    end
    cd C:\Users\Loomis\Documents\HO_FO_Spindles\Laminar1_PFC
    %save in histogram
    disp(sessf)
    %
end

imagesc(squeeze(sum(h_all,3)))