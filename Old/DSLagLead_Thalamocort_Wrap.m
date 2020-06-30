clear
tic
cd Y:\Milan\DriveDataSleep
load('subs.mat')
% loop thru subs
spind_edge = -500:1:500;
tca=[]; cta=[];
for k = [1:7]
    cd(subs{k})
    load('all_good_ctx_th_ch.mat')
    load('good_sess.mat')
    if k == 3
        good_sess = good_sess(2:3);
    end
    load('gch.mat')
    CtxCh = intersect(gch,CtxCh); ThCh = intersect(gch,ThCh);
    nCh = length(CtxCh)+length(ThCh);
    % loop thru sessions
    h_all = nan(nCh,nCh,length(good_sess),length(spind_edge)-1);
    hm = nan(nCh,nCh,length(good_sess));
    for kk = 1 : length(good_sess)
        cd(good_sess{kk})
        % run DS connectivity
        if isfile('MUA_1k.mat')
            load('MUA_1k.mat')
            if ~isempty(mua)
                load('States.mat')
                clear pk
                cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq = [.2 3.8]; cfg.bpinstabilityfix='reduce';
                mua3 = ft_preprocessing(cfg,mua);
                nCh = length(mua3.label);
                for c = 1 : nCh
                    [pka,pktmp] = findpeaks(-mua3.trial{1}(c,:)); 
                    [pktmp,pktmpi] = intersect(pktmp,time_STATE2gs(states(1).t));
                    pka = pka(pktmpi);
                    [~,sorti] = sort(pka); sorti = sorti(round(.8*length(sorti)):end);
                    pk{c} = pktmp(sorti);
                end
            %build histogram for that session, for spindle in each channel
                for c1 = 1 : nCh
                    for c2 = c1 : nCh
                        td = pk{c1} - pk{c2}'; %allpks{1}' - st'; 
                        td = td(:); td(abs(td)>=max(spind_edge))=[];
                        h = histcounts(td,spind_edge); h2=histcounts(-td,spind_edge);
                        h_all(c1,c2,kk,:) = h;
                        h_all(c2,c1,kk,:) = h2;
                        hm(c1,c2,kk) = nanmedian(td); hm(c2,c1,kk)=nanmedian(-td);
                    end
                end
            end
        end
    end
    
    tc = squeeze(nansum(h_all(ThCh,CtxCh,:,:),3));
    tc = reshape(tc,[size(tc,1)*size(tc,2) size(tc,3)]);
    tc = squeeze(nansum(tc));
    
    tca = [tca; tc];
    
    ct = squeeze(nansum(h_all(CtxCh,ThCh,:,:),3));
    ct = reshape(ct,[size(ct,1)*size(ct,2) size(ct,3)]);
    ct = squeeze(nansum(ct));
    
    cta = [cta; ct];
    
    cd(subs{k})
    save('ds_lag_lead_sub.mat','h_all','hm','tc','ct')
    disp(k)
end
cd('Y:\Milan\DriveDataSleep')
save('ds_lag_lead.mat','tca','cta')
toc