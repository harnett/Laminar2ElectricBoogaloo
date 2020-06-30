%% LIB OF FUNCTIONS

%Sleep analysis

%LFP analysis

%Spike analysis

%LFP-Spike analysis

%% TODO add analyses restricted to spindle epochs
clear
% for pfc lam - dont worry about sync vs async DS
addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\gcpp'))
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))

msfolders = {'G:\CompDoc\HO_FO_Spindles\Laminar1_PFC',...
    'G:\CompDoc\HO_FO_Spindles\PFC_A1_Lam',...
    'C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam2'};

nCh = 23;

ns = [];%nan(nCh,length(sess_folders));
msi = [];
avga=[];
avgma=[];
paca = [];
sfrqa = [];
cohzaa = [];
cohaa = [];
ppca = []; ppcza=[];
plva = []; plvza=[];
rala = []; ralza=[];
sessfa = [];
unind = 1;
staa = {};
%loop thru sessions
for msid = 3
    cd(msfolders{msid})
    load('sess_folders.mat')
    if msid == 1
        sess_folders = sess_folders(3:4);
    elseif msid == 2
        sess_folders = sess_folders(1:6);
    elseif msid == 3
        sess_folders = sess_folders([1:3]);
    end
for sessf = 1 : length(sess_folders)
    cd(sess_folders{sessf})
    %detect downstates
    load('LFP_1k.mat')
    load('MUA_1k.mat')
    load('States.mat')
    if isfile('Unitdata.mat')
        load('Unitdata.mat')
    end
    if isfile('bch.mat')
        load('bch.mat')
        
        for bintp = 1 : length(bch)
            lfp.trial{1}(bch(bintp),:) = (lfp.trial{1}(bch(bintp)-1,:) + lfp.trial{1}(bch(bintp)+1,:)) ./ 2;
        end
      
    end
    
    if length(lfp.label)>64
        cfg=[]; cfg.channel = lfp.label(1:64); lfp = ft_preprocessing(cfg,lfp);
        cfg=[]; cfg.channel = lfp.label(1:64); mua = ft_preprocessing(cfg,mua);
    end
    
    mua_orig = mua;
    
    mua_mn = zscore([mean(mua.trial{1}(1:64,:))],[],2);

    cfg=[]; cfg.channel = mua.label(1); mua = ft_preprocessing(cfg,mua);
    mua.trial{1} = mua_mn;

    cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq = [.2 2.2]; cfg.bpinstabilityfix='reduce';
    mua = ft_preprocessing(cfg,mua);
    
    rmpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12\chronux_2_12'))
    [~,pk] = findpeaks(-mua.trial{1}(1,:)); pk = intersect(pk,time_STATE2gs(states(1).t));    
    %mono vs bi
    lfp = LFP_ChanDownsamp_Mean(lfp,nCh+1);
    
    lfp.trial{1}(1:(size(lfp.trial{1},1)-1),:) = diff(lfp.trial{1});
    
    cfg=[]; cfg.channel = lfp.label(1:nCh); lfp = ft_preprocessing(cfg,lfp);
    
    cfg=[]; cfg.trl=zeros(length(pk),3); cfg.trl(:,1) = pk-1500;
    cfg.trl(:,2) = pk+1500; osc_avgd = ft_redefinetrial(cfg,lfp);
    mua_avgd = ft_redefinetrial(cfg,mua_orig);
    
    avg = ft_timelockanalysis(cfg,osc_avgd); avg = avg.avg;
    mavg = ft_timelockanalysis(cfg,mua_avgd); mavg = mavg.avg;
    
    avga = cat(3,avga,avg);
    avgma = cat(3,avgma,mavg);
    
    gs = time_STATE2gs(states(1).t);
    
    %detect spindles
    times_all = findspindlesv5(lfp,1000,9.5,16,gs,2.6);
    [a,~] = hist(times_all(:,3),unique(times_all(:,3)));
    a = a ./ length(time_STATE2gs(states(1).t)).*1000;
    ns = [ns a'];
%     
    msi = [msi msid];
    
    sessfa = [sessfa sessf];
    
    % freqxdepth plot by state
    
    [sfrq,~,fq_ax] = state_freqv2(lfp,states,5);

    sfrqa = cat(4,sfrqa,sfrq);

    % lfp-lfp PAC during spindle; redo???
    
%     pac = pac_v2([ [5:2:21]' [7:2:23]'],[100 450],lfp,st2gs(times_all));
%     paca = cat(paca,pac,4);

    %lfp-mua coherence during spindles
    mua_orig = LFP_ChanDownsamp_Mean(mua_orig,nCh);
    
%     [cohspind,cohzspind] = LFPMUA_CohZ(lfp,mua_orig,st2gs(times_all),500);
    
%lfp-mua coherence across states
    cohza = nan(length(lfp.label),length(mua_orig.label),126,3); coha = cohza; % 126 is hardcoded for parfor, depends on freq. limits
    parfor cohstate = 1 : 3
    [coh,cohz] = LFPMUA_CohZ(lfp,mua_orig,gs,200);
    cohza(:,:,:,cohstate) = cohz;
    coha(:,:,:,cohstate) = coh;
    end
    cohzaa = cat(5,cohzaa,cohza);
    cohaa = cat(5,cohaa,coha);
    %save('cohza.mat','cohza','-v7.3')
    
    % save cohs
    
%     [PACma, PACzma, ModIndma, ModIndZma] = LFPMUA_MI_Spind(lfp,mua_orig,200,times_all);
%     
%     PACaa(:,:,:,sessf) = cat(4,PACaa,PACa);
%     PACzaa(:,:,:,:,sessf) = cat(5,PACzaa,PACza);
%     ModIndaa(:,:,sessf) = cat(3,ModIndaa,ModInda);
%     ModIndZaa(:,:,sessf) = cat(3,ModIndZaa,ModIndZa);
    
    % lfp-lfp granger
    % TODO
    
    % spike analyses!
    if isfile('Unitdata.mat')
    
    %elaborate on!!!
    %scrap and parfor whole thing in more efficient way???
    [avglfp,rast_singtrial,rast_avgmean,rast_avgstd] = raster_aligned_to_osc(unitdata,lfp,states,2,1000,10,[0 4;4 8;8 16],6000);
        
    % spike - lfp coherence
    [ppc,plv,ral,ppcz,plvz,ralz,fq] = spikeLFP_continuousZ(lfp,unitdata,1:.5:55,states,200,200);
    
    unit_sessid = sessf;
    ppca = cat(3,ppca,ppc); plva = cat(3,plva,plv); rala = cat(3,rala,ral);
    ppcza = cat(3,ppcza,ppcz); plvza = cat(3,plvza,plvz); ralza = cat(3,ralza,ralz);
    
    % spike spectra
    
    spctra = spk_spectra(unitdata,states);
    
    spctraa(:,unind) = spctra;
    
    % spike-spike coherencies
    
    spkcoh = spk_coh(unitdata,states,1000);
    
    spkcoha(:,unind) = spkcoh;
    
    % spike-spike granger; emory or something else?
    % TODO
    
    % spike-lfp STA
    sta = LaminarSTA_StateWrapper_NoReReference(unitdata,lfp,2000,1000,[],states,[]);
    staa{unind} = sta;
    
    % spike-spike cross correlations!
    cch_rla = nan(length(unitdata),length(unitdata),201,3); cch_preda = cch_rla; cch_proba = cch_rla; sigflaga = nan(length(unitdata),length(unitdata),3);
    parfor xcstate = 1 : 3 % MAKE THIS A PARFOR
        gs = time_STATE2gs(states(xcstate).t);
        [cch_rl,cch_pred,cch_prob,sigflag] = xcorrTimestampsCumPoiss(unitdata,[],[],gs);
        cch_rla(:,:,:,xcstate) = cch_rl;% = cat(4,cch_rla,cch_rl);
        cch_preda(:,:,:,xcstate) = cch_pred;
        cch_proba(:,:,:,xcstate) = cch_prob;
        sigflaga(:,:,xcstate) = sigflag;
    end
    save('xcorrs.mat','cch_rla','cch_preda','cch_proba','sigflag','-v7.3')
    % ADD firing rate contrast across states
    [fra,meanfr,sig_fr] = FiringRate_Across_States(unitdata,states);
    
    save('firing_rate_stats.mat','fra','meanfr','sig_fr')
    
    msi_u = [msi_u msid];
    sessfa_u = [sessfa_u sessf];
    
    unind = unind + 1;
    
    end
    %save in histogram
    disp(sessf)
    %
end

end