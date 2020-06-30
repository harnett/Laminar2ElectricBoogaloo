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

sess_folders = sess_folders(1:6);

nCh = 15;

%loop thru sessions
ns = nan(nCh*2,length(sess_folders));

cd C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam

spind_edge = -4000:5:4000;

tl = 1000;
tda = nan(nCh*2,nCh*2,length(spind_edge)-1);
tdaa = nan(nCh*2,nCh*2,length(spind_edge)-1,length(sess_folders));
tda_sum = nan(length(sess_folders),length(spind_edge)-1);
co_occa = nan(nCh*2,nCh*2,length(sess_folders)); co_occ_lim = 200;
mna = nan(nCh*2, nCh*2, length(sess_folders));
mla = mna;
for sessf = 1 : length(sess_folders)
    cd(sess_folders{sessf})
    %detect downstates
    load('LFP_1k.mat')
    load('States.mat')
    
    co_occ = nan(nCh*2,nCh*2);
    
    lfp = LFP_ChanDownsamp_Mean_DualLam(lfp,nCh+1);
    
    lfp.trial{1}(1:(size(lfp.trial{1},1)-1),:) = diff(lfp.trial{1});
    
    cfg=[]; cfg.channel = lfp.label([1:nCh (nCh+2):(size(lfp.trial{1},1)-1)]); lfp = ft_preprocessing(cfg,lfp);
    
    %detect spindles
    times_all = findspindlesv5(lfp,1000,9.5,16,time_STATE2gs(states(1).t),2.9);
    [a,~] = hist(times_all(:,3),unique(times_all(:,3)));
    ns(:,sessf) = a';
    
    %st = mean(times_all(:,1:2),2);
    st = (times_all(:,1));
    if isempty(st)
        continue
    end
        for kkk = 1:(nCh*2)%loop thru ctx ch
            for kkkk = kkk:(nCh*2)%loop thru thal ch
                s1=st(find(times_all(:,3)==kkk));
                s2=st(find(times_all(:,3)==kkkk));
                td=(s1'-s2);
                if isempty(td)
                    continue
                end
                co_occ(kkk,kkkk) = length(find(min(abs(td),[],2)<=co_occ_lim))./length(s2);
                co_occ(kkkk,kkk) =length(find(min(abs(td))<=co_occ_lim))./length(s1);
                td = td(:);
                td(abs(td)>=max(spind_edge))=[];
                tda(kkk,kkkk,:) = histcounts(td,spind_edge);
                tda(kkkk,kkk,:) = histcounts(-td,spind_edge);
                mna(kkk,kkkk,sessf) = nanmean(td); mna(kkkk,kkk,sessf) = -mna(kkk,kkkk,sessf);
                mda(kkk,kkkk,sessf) = median(td); mda(kkkk,kkk,sessf) = -mda(kkk,kkkk,sessf);
            end
        end
        
        co_occa(:,:,sessf) = co_occ;
        
        td_sum=(st(find(times_all(:,3)<=15))'-st(find(times_all(:,3)>=16)));
        td_sum = td_sum(:);
        td_sum(abs(td_sum)>=max(spind_edge))=[];
        tdmn(sessf) = mean(td_sum);
        tdmd(sessf) = median(td_sum);
        tda_sum(sessf,:) = histcounts(td_sum,spind_edge);
        
        tdaa(:,:,:,sessf) = tda;
        disp(sessf)
        save('DualLamSpindleLags.mat','tda','a','td_sum','co_occ','-v7.3')
        cd C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam
end
cd C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam
save('DualLamSpindleLagsAll.mat','tdaa','ns','tda_sum','co_occa','mna','mda','tdmn','tdmd','-v7.3')