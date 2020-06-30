clear
% for pfc lam - dont worry about sync vs async DS
addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))

cd Y:\Milan\DriveDataSleep\Grik4_No4
sess_folders={'Y:\Milan\DriveDataSleep\Grik4_No4\2019-11-13_14-37-33_GRIK4_no4_sleep',...
    'Y:\Milan\DriveDataSleep\Grik4_No4\2019-11-14_12-36-47_GRIK4_no4_sleep'};

spind_edge = -4000:50:4000;

nCh = 15;

fqs = [[.2:.2:2.2]' [1:.2:3]'];

h_all = nan(nCh,length(spind_edge)-1,length(sess_folders),length(fqs));
%loop thru sessions
for sessf = 1 : length(sess_folders)
    cd(sess_folders{sessf})
    %detect downstates
    load('LFP_1k.mat')
    load('MUA_1k.mat')
    load('States.mat')

    mua_mn = zscore(mean(mua.trial{1}(1:4,:)),[],2);

    cfg=[]; cfg.channel = mua.label(1); mua2 = ft_preprocessing(cfg,mua);
    mua2.trial{1} = mua_mn;
    
    %detect spindles
    times_all = findspindlesv5(data,1000,9.5,16,time_STATE2gs(states(1).t),2.6);
    
    for f = 1:size(fqs,1)
    cfg=[]; cfg.lpfilter='yes'; cfg.lpfreq = [fqs(f,1) fqs(f,2)]; cfg.bpinstabilityfix='reduce';
    mua3 = ft_preprocessing(cfg,mua2);

    [~,pk] = findpeaks(-mua3.trial{1}(1,:)); pk = intersect(pk,time_STATE2gs(states(1).t));
    %build histogram for that session, for spindle in each channel
    for k = 1 : nCh
    st=(mean(times_all(find(times_all(:,3)==k),1:2),2));

    td = pk' - st'; %allpks{1}' - st'; 
    td = td(:); td(abs(td)>=max(spind_edge))=[];
    h = histcounts(td,spind_edge);
    h_all(k,:,sessf,f) = h;
    end
    cd Y:\Milan\DriveDataSleep\Grik4_No4
    end
    %save in histogram

    %
end

for k = 1 : length(fqs)
subplot(4,3,k)
imagesc(squeeze(h_all(:,:,1,k)))
end
figure
for k = 1 : 15
subplot(3,5,k)
histogram('BinCounts',squeeze(h_all(11,:,2,k)),'BinEdges',spind_edge), xlim([-500 500])
end

histogram('BinCounts',squeeze(h_all(10,:)'),'BinEdges',spind_edge)
