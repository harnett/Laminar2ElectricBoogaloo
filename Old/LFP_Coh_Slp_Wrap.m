clear
cd Y:\Milan\DriveDataSleep
load subs.mat
ca=[]; subsi=[]; bi=[0 0 0 0 0 0];
for k = [1 3:6]
    cd(subs{k})
    load('good_sess.mat')
    load('good_ctx_th_ch.mat')
    csub=[];
    for kk = 1 : length(good_sess)
        cd(good_sess{kk})
        load('States.mat')
        if bi(k)
            load('LFPBi_StCh.mat')
        else
            load('LFP_1k.mat')
            cfg=[]; cfg.channel=data.label(good_ctx_th_ch); 
            data = ft_preprocessing(cfg,data);
        end
        data.fsample = 1000;
        data = contgs2seg(data,2,time_STATE2gs(states(1).t));
        coh = Coh_Fieldtrip(data,[],[0 45],[]);
        save('lfpcoh_sess2.mat','coh')
        c = squeeze(abs(coh.cohspctrm(1,2,:))); fx = coh.freq;
        csub = [csub c];
        subsi = [subsi k];
    end
    cd(subs{k})
    ca = [ca csub];
    save('lfpcoh_sub2.mat','csub','fx')
    disp(k)
end
cd Y:\Milan\DriveDataSleep
save('lfpcoh_all2.mat','ca','subsi','fx')