addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\djh'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\SharedSpectralAnalysisforZip'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))

clear

cd Y:\Milan\DriveDataSleep

load('subs')

saa = []; subsi=[];
for k = 1 : length(subs)
    cd(subs{k})
    load('good_sess.mat')
    load('good_ctx_th_ch.mat')
    sa=[];
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        %if ~isfile('spkr_res.mat')
        load('LFP_1k.mat')
        cfg=[]; cfg.channel = data.label(good_ctx_th_ch); data=ft_preprocessing(cfg,data);
        load('States.mat')
        load('unitdata.mat')
        times_all = findspindlesv5(data,1000,9,17,time_STATE2gs(states(1).t));
        spkcoh=spk_coh_spindle(unitdata,times_all);
        a = cell(1,length(unitdata));
        for kkk =1 : length(unitdata)
            a{kkk} = unitdata(kkk).area;
        end
        [~,~,a]=unique(a);
        s = spkcoh.C(find(a==1),find(a==2),:);
        s = reshape(s,[size(s,1).*size(s,2) size(s,3)]);
        fx = spkcoh.f;
        save('spkcoh_spindle.mat','spkcoh')
        save('spkcoh_spindle_thalamocort.mat','s','fx')
        subsi=[subsi ones(1,length(a)).*k];
        sa = [sa; s];
    end
    cd(subs{k})
    saa = [saa; sa];
    save('spkcoh_spindle_sub.mat','sa','fx')
    disp(k)
end

cd Y:\Milan\DriveDataSleep
save('spkcoh_spindle_all.mat','saa','fx','subsi')