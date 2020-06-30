clear
tic
cd Y:\Milan\DriveDataSleep
load('subs.mat')
% loop thru subs
spind_edge = -500:1:500;
tca=[]; avgmua_all = [];
for k = [1:7]
    avgmuasub=[];
    cd(subs{k})
    load('all_good_ctx_th_ch.mat')
    load('good_sess.mat')
    if k == 3
        good_sess = good_sess(2:3);
    end
    load('gch.mat')
    CtxCh = intersect(gch,CtxCh); ThCh = intersect(gch,ThCh);
    % loop thru sessions
    h_all = nan(length(good_sess),length(spind_edge)-1);
    for kk = 1 : length(good_sess)
        cd(good_sess{kk})
        % run DS connectivity
        if isfile('MUA_1k.mat')
            load('MUA_1k.mat')
            if ~isempty(mua)
                load('States.mat')
                cfg=[]; cfg.channel = mua.label(CtxCh); CtxMua = ft_preprocessing(cfg,mua);
                cfg=[]; cfg.channel = mua.label(ThCh); ThMua = ft_preprocessing(cfg,mua);   
                CtxMua.trial{1}(1,:) = mean(CtxMua.trial{1}); cfg=[]; cfg.channel=CtxMua.label(1); CtxMua = ft_preprocessing(cfg,CtxMua);
                ThMua.trial{1}(1,:) = mean(ThMua.trial{1}); cfg=[]; cfg.channel=ThMua.label(1); ThMua = ft_preprocessing(cfg,ThMua);
                clear pk
                CtxMuaO = CtxMua; ThMuaO = ThMua;
                cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq = [1 4]; cfg.bpinstabilityfix='reduce';
                CtxMua = ft_preprocessing(cfg,CtxMua);
                ThMua = ft_preprocessing(cfg,ThMua);
                [pka,pktmp] = findpeaks(-CtxMua.trial{1}); 
                [pktmp,pktmpi] = intersect(pktmp,time_STATE2gs(states(1).t));
                pka = pka(pktmpi);
                [~,sorti] = sort(pka); sorti = sorti(round(.9*length(sorti)):round(1*length(sorti)));
                CtxPk = pktmp(sorti);
                
                trl = zeros(length(CtxPk),3); trl(:,1) = CtxPk-2000; trl(:,2) = CtxPk+2000;
                cfg=[]; cfg.trl = trl; CtxMuaO = ft_redefinetrial(cfg,CtxMuaO); ThMuaO = ft_redefinetrial(cfg,ThMuaO);
                CtxMuaO = ft_timelockanalysis(cfg,CtxMuaO);
                ThMuaO = ft_timelockanalysis(cfg,ThMuaO);
                
                avgmua = [CtxMuaO.avg; ThMuaO.avg];
                avgmuasub = cat(3,avgmuasub,avgmua);
                
                [pka,pktmp] = findpeaks(-ThMua.trial{1}); 
                [pktmp,pktmpi] = intersect(pktmp,time_STATE2gs(states(1).t));
                pka = pka(pktmpi);
                [~,sorti] = sort(pka); sorti = sorti(round(.6*length(sorti)):end);
                ThPk = pktmp(sorti);
                %build histogram for that session, for spindle in each channel
                td = ThPk - CtxPk'; %allpks{1}' - st'; 
                td = td(:); td(abs(td)>=max(spind_edge))=[];
                h = histcounts(td,spind_edge);
                h_all(kk,:) = h;
            end
        end
    end
    
    tc = squeeze(nansum(h_all,1));
    
    tca = [tca; tc];
    
    avgmua_all = cat(3,avgmua_all,squeeze(nanmean(avgmuasub,3)));
    
    cd(subs{k})
    save('ds_lag_lead_sub_avgs.mat','h_all','tc','avgmuasub')
    disp(k)
end
cd('Y:\Milan\DriveDataSleep')
save('ds_lag_lead_avgs.mat','tca','avgmua_all')
toc

figure
for k = 1 : 6
subplot(2,3,k)
plot(zscore(squeeze(avgmua_all(1,:,k)))), hold on, plot(zscore(squeeze(avgmua_all(2,:,k))))
end

figure
for k = [1:7]
subplot(2,4,k)
histogram('BinCounts',tca(k,:),'BinEdges',spind_edge), xlim([-50 50])
title(mean(tca(k,450:500),2)-mean(tca(k,501:550),2))
end