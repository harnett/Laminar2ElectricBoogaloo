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

spind_edge = -600:2:600;

nCh = 15;

fqs = [[.2:.2:2.2]' [1:.2:3]'];

h_all = nan(nCh,nCh,length(sess_folders),length(spind_edge)-1);
hm = nan(nCh,nCh,length(sess_folders));
%loop thru sessions
for sessf = 1 : length(sess_folders)
    cd(sess_folders{sessf})
    %detect downstates
    %load('LFP_1k.mat')
    load('MUA_1k.mat')
    load('States.mat')
    clear pk
    cfg=[]; cfg.lpfilter='yes'; cfg.lpfreq = 2; cfg.lpinstabilityfix='reduce';
    mua3 = ft_preprocessing(cfg,mua);
    
    for k = 1 : nCh
    [~,pk{k}] = findpeaks(-mua3.trial{1}(k,:)); pk{k} = intersect(pk{k},time_STATE2gs(states(1).t));
    end
    %build histogram for that session, for spindle in each channel
    for k = 1 : nCh
        for kk = k : nCh
    td = pk{k} - pk{kk}'; %allpks{1}' - st'; 
    td = td(:); td(abs(td)>=max(spind_edge))=[];
    h = histcounts(td,spind_edge); h2=histcounts(-td,spind_edge);
    h_all(k,kk,sessf,:) = h;
    h_all(kk,k,sessf,:) = h2;
    hm(k,kk,sessf) = nanmedian(td); hm(kk,k,sessf)=nanmedian(-td);
        end
        disp(k)
    end
    cd Y:\Milan\DriveDataSleep\Grik4_No4
    %save in histogram

    %
end

thch=10:12; ctxch=[1:8 13:15];
tc = squeeze(sum(h_all(thch,ctxch,:,:),3));
tc = reshape(tc,[size(tc,1)*size(tc,2) size(tc,3)]);
tc = squeeze(sum(tc));
histogram('BinCounts',tc,'BinEdges',spind_edge), xlim([-500 500])

ct = squeeze(sum(h_all(ctxch,thch,:,:),3));
ct = reshape(ct,[size(ct,1)*size(ct,2) size(ct,3)]);
ct = squeeze(sum(ct));
histogram('BinCounts',ct,'BinEdges',spind_edge), xlim([-500 500])