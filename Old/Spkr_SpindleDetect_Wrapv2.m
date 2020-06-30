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

for k = 1 : length(subs)
    cellarea_all = [];
    cd(subs{k})
    load('good_sess.mat')
    load('good_ctx_th_ch.mat')
    rsa=[]; zsa=[]; pvsa=[]; angsa=[];
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        %if ~isfile('spkr_res.mat')
        load('LFP_1k.mat')
        cfg=[]; cfg.channel = data.label(good_ctx_th_ch); data=ft_preprocessing(cfg,data);
        load('States.mat')
        load('unitdata.mat')
        [st,spr] = spindle_detector_Xi_v3(data,time_STATE2gs(states(1).t));
        spind_gs = st2gs(st{1});
        data.fsample = 1000;
        [rs,zs,pvs,angs] = spk_rtest(data,unitdata,[.5 3.5;10 17],spind_gs,1000);
        rsa = cat(3,rsa,rs); zsa = cat(3,zsa,zs); pvsa = cat(3,pvsa,pvs); angsa = cat(3,angsa,angs);
        cellarea=zeros(1,length(unitdata));
        for ck = 1 : length(unitdata)
            a = unitdata(ck).area;
            if strcmp(a,'PFC') || strcmp(a,'A1')
                cellarea(ck) = 1;
            end
        end
        cellarea_all = [cellarea_all cellarea];
        save('spkr_res.mat','rs','zs','pvs','angs','cellarea')
        save('spind_res_Xi.mat','st','spr')
        %end
    end
    cd(subs{k})
    save('spkr_sum.mat','rsa','zsa','pvsa','angsa','cellarea_all')
    disp(k)
end

%%
cd Y:\Milan\DriveDataSleep

load('subs')

for k = 1 : length(subs)
    cd(subs{k})
    load('good_sess.mat')
    area=[]; aa={};
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        load('unitdata.mat')
        a = cell(1,length(unitdata));
        for kkk =1 : length(unitdata)
            a{kkk} = unitdata(kkk).area;
        end
        [~,~,areatmp]=unique(a);
        area = [area; areatmp];
        aa = [aa a];
    end
    cd(subs{k})
    save('area.mat','area','aa')
    disp(k)
end

%%

% compare cortex vs. thalamus strength