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
sess_folders = sess_folders(1:4);
spind_edge = -4000:50:4000;
nCh = 23;%15
h_all = nan(nCh*2,length(spind_edge)-1,length(sess_folders),3); % last dimension is downstate on each laminar
h_all_ss = nan(nCh*2,nCh*2,length(spind_edge)-1,length(sess_folders),3);
%loop thru sessions
ns = nan(nCh*2,length(sess_folders)); nd = nan(3,length(sess_folders));
spind_ds_counts = nan(nCh*2, length(sess_folders), 3);
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
cc = zeros(1,length(pk1));
for k = 1 : length(pk1)
td = pk2 - pk1(k);
if ~isempty(find(abs(td)<=60))
cc(k) = 1;
end
end
pksync = pk1(find(cc==1));
pk1 = pk1(find(cc==0));
cc = zeros(1,length(pk2));
for k = 1 : length(pk2)
td = pk1 - pk2(k);
if ~isempty(find(abs(td)<=50))%100
cc(k) = 1;
end
end
pk2 = pk2(find(cc==0));
nd(:,sessf) = [length(pk1) length(pk2) length(pksync)];
%detect spindles
times_all = findspindlesv5(lfp,1000,8.8,16,time_STATE2gs(states(1).t),3.2);%9.5 16
sdat = lfp; sdat.trial{1} = zeros(size(lfp.trial{1},1),size(lfp.trial{1},2));
for k = 1 : size(lfp.trial{1},1)
    st = times_all(find(times_all(:,3)==k),1:2);
    for kk = 1 : size(st,1)
        sdat.trial{1}(k,st(kk,1):st(kk,2)) = 1;
    end
end

s1 = sum(sdat.trial{1}(1:nCh,:)); s2 = sum(sdat.trial{1}((nCh+1):end,:)); 
s1(s1<1) = 0; s1(s1~=0) = 1; s2(s2<1) = 0; s2(s2~=0) = 2;
pk1s = s1(pk1 + 250) + s2(pk1+250);
pk2s = s1(pk2 + 250) + s2(pk2+250);
pksyncs = s1(pksync + 250) + s2(pksync+250);
pkss{sessf,1} = pk1s;
pkss{sessf,2} = pk2s;
pkss{sessf,3} = pksyncs;
[a,~] = hist(times_all(:,3),unique(times_all(:,3))); a = 1000.* a ./ length(time_STATE2gs(states(1).t));
ns(:,sessf) = a';
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
td = pksync' - st'; %allpks{1}' - st';
td = td(:); td(abs(td)>=max(spind_edge))=[];
h = histcounts(td,spind_edge);
h_all(k,:,sessf,3) = h;
end
for k = 1 : (nCh*2)
    st=(mean(times_all(find(times_all(:,3)==k),1:2),2));
    stpk1 = st-pk1; stpk1(stpk1<0) = nan; st_pk1 = st(find(min(stpk1')<=400));
    stpk2 = st-pk2; stpk2(stpk2<0) = nan; st_pk2 = st(find(min(stpk2')<=400));
    stpksync = st-pksync; stpksync(stpksync<0) = nan; st_pksync = st(find(min(stpksync')<=400));
    spind_ds_counts(k,sessf,:) = [length(st_pk1) length(st_pk2) length(st_pksync)];
    for kk = 1 : (nCh*2)
        st2=(mean(times_all(find(times_all(:,3)==kk),1:2),2));
        td = st2' - st_pk1; %allpks{1}' - st';
        td = td(:); td(abs(td)>=max(spind_edge))=[];
        h = histcounts(td,spind_edge);
        h_all_ss(k,kk,:,sessf,1) = h;
        st2=(mean(times_all(find(times_all(:,3)==kk),1:2),2));
        td = st2' - st_pk2; %allpks{1}' - st';
        td = td(:); td(abs(td)>=max(spind_edge))=[];
        h = histcounts(td,spind_edge);
        h_all_ss(k,kk,:,sessf,2) = h;
        st2=(mean(times_all(find(times_all(:,3)==kk),1:2),2));
        td = st2' - st_pksync; %allpks{1}' - st';
        td = td(:); td(abs(td)>=max(spind_edge))=[];
        h = histcounts(td,spind_edge);
        h_all_ss(k,kk,:,sessf,3) = h;
    end
end
cd C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam
%save in histogram
disp(sessf)
%
end
%% plot # of spindles
shadedErrorBar(1:23,nanmean(ns(1:23,:),2)*60,60*std(ns(1:23,:),[],2)./2), hold on
shadedErrorBar(1:23,nanmean(ns(24:46,:),2)*60,60*std(ns(24:46,:),[],2)./2), hold on
%% 