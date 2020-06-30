addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\djh'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\SharedSpectralAnalysisforZip'))

clear

cd Y:\Milan\DriveDataSleep

load('subs')

for k = 5 %: length(subs)
    cd(subs{k})
    load('good_sess.mat')
    load('good_ctx_th_ch.mat')
    yaa=[]; yaanons=[];
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        %if ~isfile('spkr_res.mat')
        load('LFP_1k.mat')
        cfg=[]; cfg.channel = data.label(good_ctx_th_ch); data=ft_preprocessing(cfg,data);
        load('States.mat')
        times_all = findspindlesv5(data,1000,7,13,time_STATE2gs(states(1).t),2.8);
        st = times_all(find(times_all(:,3)==1),1:2);
        st_nons = st; stl = st_nons(:,2)-st_nons(:,1); st_nons(:,1) = st_nons(:,2); st_nons(:,2) = st_nons(:,2) + stl;
        cfg=[]; cfg.trl=zeros(size(st,1),3); cfg.trl(:,1) = st(:,1); cfg.trl(:,2) = st(:,2); s = ft_redefinetrial(cfg,data);
        cfg=[]; cfg.trl=zeros(size(st_nons,1),3); cfg.trl(:,1) = st_nons(:,1); cfg.trl(:,2) = st_nons(:,2); nons = ft_redefinetrial(cfg,data);
        data.fsample = 1000;
        [ya,fx] = fft_trl(s,[]);
        [yanons,~] = fft_trl(nons,[]);
        save('spind_res_findspind.mat','times_all')
        save('spind_fft.mat','ya','yanons','fx')
        yaa = cat(3,yaa,ya); yaanons = cat(3,yaanons,yanons);
    end
    cd(subs{k})
    save('spindfft_sum.mat','yaa','yaanons','fx')
    disp(k)
end