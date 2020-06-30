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

bi = [1 0 0 0 1 0];

for k = [3:4 6]
    cd(subs{k})
    load('good_sess.mat')
    load('good_ctx_th_ch.mat')
    dphss=[];
    for kk = 1 : length(good_sess)
        dphs=[];
        cd(good_sess{kk}) 
        
        load('LFP_1k.mat')
        cfg=[]; cfg.channel = data.label(good_ctx_th_ch); data=ft_preprocessing(cfg,data);
        load('States.mat')
        times_all = findspindlesv5(data,1000,9,17,time_STATE2gs(states(1).t),2.2);
        st = times_all(find(times_all(:,3)==1),1:2);
        [dphs,pv,z] = spind_delta_phscoupling(data,times_all(times_all(:,3)==1,1:2));
        save('sess_dphs.mat','dphs')
        dphss = [dphss dphs];
    end
    cd(subs{k})
    [~,cds] = sort(abs(circ_dist(dphss,circ_mean(dphss'))));
    save('spind_dist_dphs.mat','cds','dphss')
    disp(k)
end