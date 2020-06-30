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
    cd(subs{k})
    load('good_sess.mat')
    load('gch.mat')
    rsa=[]; zsa=[]; pvsa=[]; angsa=[];
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        if ~isfile('spkr_res.mat')
        load('LFP_1k.mat')
        cfg=[]; cfg.channel = data.label(gch); data=ft_preprocessing(cfg,data);
        load('States.mat')
        load('unitdata.mat')
        [st,spind_gs,st_a] = detectSS_djh_ms(data,states);
        data.fsample = 1000;
        [rs,zs,pvs,angs] = spk_rtest(data,unitdata,[.5 3.5;8.5 16],spind_gs,1000);
        rsa = cat(3,rsa,rs); zsa = cat(3,zsa,zs); pvsa = cat(3,pvsa,pvs); angsa = cat(3,angsa,angs);
        save('spkr_res.mat','rs','zs','pvs','angs')
        save('spind_res.mat','st','spind_gs','st_a')
        end
    end
    cd(subs{k})
    save('spkr_sum.mat','rsa','zsa','pvsa','angsa')
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