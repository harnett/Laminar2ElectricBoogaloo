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
    uia=[];
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        if bi(k)
            load('LFPBi_StCh.mat')
            cfg=[]; cfg.channel = data.label(1); data=ft_preprocessing(cfg,data);
        else
        load('LFP_1k.mat')
        cfg=[]; cfg.channel = data.label(good_ctx_th_ch(1)); data=ft_preprocessing(cfg,data);
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
        st = time_STATE2gs(states(1).t);
        if ~isempty(st)
        [avglfp,rast_singtrial,rast_avgmean,rast_avgstd] = raster_aligned_to_spind(unitdata,data,...
            st,1,1000,1,[.5 3.5],10000);
        save('delta_avg_sess2.mat','avglfp','ui','rast_singtrial','rast_avgmean','rast_avgstd','-v7.3')
        avglfpa=[avglfpa; avglfp];
        rast_avgmeana=[rast_avgmeana; rast_avgmean];
        rast_avgstda=[rast_avgstda; rast_avgstd];
        uia = [uia ui];
        end
    end
    cd(subs{k})
    save('delta_avg_sub2.mat','avglfpa','uia','rast_avgmeana','rast_avgstda','-v7.3')
    disp(k)
end