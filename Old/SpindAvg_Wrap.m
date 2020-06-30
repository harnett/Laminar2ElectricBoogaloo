%bipolar_wrap
addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\djh'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
%%
clear

cd Y:\Milan\DriveDataSleep

load('subs')
bi = [1 1 1 1 1 1];
for k = [1 3:6]
    cd(subs{k})
    load('good_sess.mat')
    load('good_ctx_th_ch.mat')
    avglfpa=[];
    rast_avgmeana=[];
    rast_avgstda=[];
    avglfp_uca=[];
    rast_avgmean_uca=[];
    rast_avgstd_uca=[];
    avglfp_ca=[];
    rast_avgmean_ca=[];
    rast_avgstd_ca=[];
    dphss=[];
    uia=[];
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        if bi(k)
            load('LFPBi_StCh.mat')
            %cfg=[]; cfg.channel = data.label(1); data=ft_preprocessing(cfg,data);
        else
        load('LFP_1k.mat')
        cfg=[]; cfg.channel = data.label(good_ctx_th_ch); data=ft_preprocessing(cfg,data);
        if good_ctx_th_ch(1) > good_ctx_th_ch(2)
            data.trial{1} = data.trial{1}([2 1],:);
        end
        end
        load('States.mat')
        load('unitdata.mat')
        ui=[];
        for uind = 1 : length(unitdata)
            if strcmp('MD',unitdata(uind).area) || strcmp('MGB',unitdata(uind).area)
                ui = [ui 2];
            else
                ui = [ui 1];
            end
        end
        data.fsample = 1000;
        times_all = findspindlesv5(data,1000,9,17,time_STATE2gs(states(1).t),2.8);
        if isempty(times_all(:,3)==1)
            times_all = times_all(times_all(:,3)==2,:);
        else
            times_all = times_all(times_all(:,3)==1,:);
        end
        if ~isempty(times_all)
        [dphs,pv,z] = spind_delta_phscoupling(data,times_all(:,1:2));
        dphss = [dphss dphs];
        [~,cds] = sort(abs(circ_dist(dphs,circ_mean(dphs'))));
        [avglfp,rast_singtrial,rast_avgmean,rast_avgstd] = raster_aligned_to_spind(unitdata,data,...
            st2gs(times_all(:,1:2)),1,1000,1,[9 17],10000);
        [avglfp_c,rast_singtrial_c,rast_avgmean_c,rast_avgstd_c] = raster_aligned_to_spind(unitdata,data,...
            st2gs(times_all(cds(1:round(length(cds)./4)),1:2)),1,1000,1,[9 17],10000);
        [avglfp_uc,rast_singtrial_uc,rast_avgmean_uc,rast_avgstd_uc] = raster_aligned_to_spind(unitdata,data,...
            st2gs(times_all(cds((1+round(length(cds).*.75)):end),1:2)),1,1000,1,[9 17],10000);
        save('spind_avg_sess4.mat','avglfp','ui','rast_singtrial','rast_avgmean','rast_avgstd','avglfp_c','rast_singtrial_c','rast_avgmean_c','rast_avgstd_c','avglfp_uc','rast_singtrial_uc','rast_avgmean_uc','rast_avgstd_uc','dphs','-v7.3')
        avglfpa=cat(3,avglfpa,avglfp);
        rast_avgmeana=[rast_avgmeana; rast_avgmean];
        rast_avgstda=[rast_avgstda; rast_avgstd];
        avglfp_uca=cat(3,avglfp_uca,avglfp_uc);
        rast_avgmean_uca=[rast_avgmean_uca;rast_avgmean_uc];
        rast_avgstd_uca=[rast_avgstd_uca;rast_avgstd_uc];
        avglfp_ca=cat(3,avglfp_ca,avglfp_c);
        rast_avgmean_ca=[rast_avgmean_ca;rast_avgmean_c];
        rast_avgstd_ca=[rast_avgstd_ca;rast_avgstd_c];
        uia = [uia ui];
        end
    end
    cd(subs{k})
    save('spind_avg_sub4.mat','avglfpa','uia','rast_avgmeana','rast_avgstda','dphss','avglfp_ca','rast_avgmean_ca','rast_avgstd_ca','avglfp_uca','rast_avgmean_uca','rast_avgstd_uca','-v7.3')
    disp(k)
end