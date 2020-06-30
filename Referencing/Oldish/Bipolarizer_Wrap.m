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

for k = 1 : length(subs)
    cd(subs{k})
    load('good_sess.mat')
    load('all_good_ctx_th_ch.mat')
    load('gch.mat')
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        load('LFP_1k.mat')
        load('States.mat')
        data.fsample = 1000;
        CtxCh = intersect(gch,CtxCh); ThCh = intersect(gch,ThCh);
        cfg=[]; cfg.channel = data.label([CtxCh ThCh]);
        [data,bictxch,bithch] = lfp_bipolarizer(data,{[1:length(CtxCh)],[(length(CtxCh)+1):(length(ThCh)+length(CtxCh))]});
        save('LFPBi_1k.mat','data','bictxch','bithch','-v7.3')
        times_all = findspindlesv5(data,1000,9,17,time_STATE2gs(states(1).t),2.2);
        save('times_all_lfpbi.mat','times_all')
        n_sch = zeros(1,length(data.label));
        if ~isempty(times_all)
        sch = unique(times_all(:,3));
        for kkk = 1 : length(sch)
            n_sch(sch(kkk)) = length(find(times_all(:,3)==sch(kkk)));
        end
    [~,ctxmx] = max(n_sch(bictxch)); ctxmx = bictxch(ctxmx); 
    [~,thmx] = max(n_sch(bithch)); thmx = bithch(thmx);
    cfg=[]; cfg.channel = data.label([ctxmx thmx]); data=ft_preprocessing(cfg,data);
    times_all = times_all(union(find(times_all(:,3)==ctxmx),...
        find(times_all(:,3)==thmx)),:);
    save('LFPBi_StCh.mat','data','times_all','ctxmx','thmx','-v7.3')
        end
    end
    cd(subs{k})
    disp(k)
end
%%

            