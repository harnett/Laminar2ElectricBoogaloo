addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\djh'))

clear

cd Y:\Milan\DriveDataSleep

load('subs')

subsi=[]; dphsa=[]; sdpva=[]; sdza=[]; sessia=[];
for k = [3:4 6]
    cd(subs{k})
    load('good_sess.mat')
    load('good_ctx_th_ch.mat')
    rsa=[]; zsa=[]; pvsa=[]; angsa=[]; sdpv=[]; sdz=[]; dphss=[]; sessi=[];
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        %if ~isfile('spkr_res.mat')
        load('LFP_1k.mat')
        cfg=[]; cfg.channel = data.label(good_ctx_th_ch); data=ft_preprocessing(cfg,data);
        if good_ctx_th_ch(1) > good_ctx_th_ch(2)
            data.trial{1} = data.trial{1}([2 1],:);
        end
        load('States.mat')
        load('unitdata.mat')
        times_all = findspindlesv5(data,1000,9,17,time_STATE2gs(states(1).t),2.8);
        if ~isempty(times_all)
        spind_gs = st2gs(times_all);
        cfg=[]; cfg.channel = data.label(1); data1=ft_preprocessing(cfg,data);
        [dphs,pv,z] = spind_delta_phscoupling(data1,times_all(times_all(:,3)==1,1:2));
        sdpv = [sdpv pv]; sdz = [sdz z]; dphss = [dphss dphs]; sessi = [sessi ones(1,length(dphs)).*kk];
        save('spind_delt_coupling3.mat','pv','z','dphs')
        data.fsample = 1000;
        % get r-value for all
        
        [rs,zs,pvs,angs] = spk_rtest(data,unitdata,[.5 3.5;9 17],spind_gs,1000);
        rsa = cat(3,rsa,rs); zsa = cat(3,zsa,zs); pvsa = cat(3,pvsa,pvs); angsa = cat(3,angsa,angs);
        save('spkr_res3.mat','rs','zs','pvs','angs')
        
        save('spind_res_findspind3.mat','times_all')
        end
    end
    subsi=[subsi ones(1,length(sdpv)).*k];
    sdpva = [sdpva sdpv]; sdza = [sdza sdz]; dphsa = [dphsa dphss]; sessia = [sessia sessi];
    cd(subs{k})
    
     save('spkr_sum3.mat','rsa','zsa','pvsa','angsa','sessia')
    
    save('spind_delta_sub3.mat','sdpv','sdz','dphss','sessi')
    disp(k)
end
cd Y:\Milan\DriveDataSleep
save('spind_delta_all2.mat','sdpva','sdza','subsi','dphsa','sessia')