function [st,spr] = spindle_detector_Xi_v2(lfp,gs)
rmpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
%filter signal 10-16
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[2 50]; lfpf = ft_preprocessing(cfg,lfp);
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[8.5 17]; spind = ft_preprocessing(cfg,lfp);
%get theta and beta amplitudes as well
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[4 6]; cfg.bpinstabilityfix='reduce'; theta = ft_preprocessing(cfg,lfp); cfg=[]; cfg.hilbert = 'abs'; theta = ft_preprocessing(cfg,theta); 
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[19 25]; beta = ft_preprocessing(cfg,lfp); cfg=[]; cfg.hilbert = 'abs'; beta = ft_preprocessing(cfg,beta); 

%get analytic amplitude
cfg=[]; cfg.hilbert = 'abs'; spindenv = ft_preprocessing(cfg,spind);
%convolve with tukey window 600 ms
wpk=tukeywin(600); wss=tukeywin(300);
spindenv_pk = spindenv.trial{1}; spindenv_ss = spindenv_pk;
% for k = 1 : size(spindenv_pk,1)
%     spindenv_pk(k,:) = filtfilt(wpk,1,spindenv.trial{1}(k,:));
%     spindenv_ss(k,:) = filtfilt(wss,1,spindenv.trial{1}(k,:));
% end
%find local maxima, throw out all less than m + 2 SD


for k = 1 : size(spindenv_pk,1)
    spindenv_pk(k,:) = filtfilt(wpk,1,spindenv.trial{1}(k,:));
    spindenv_ss(k,:) = filtfilt(wss,1,spindenv.trial{1}(k,:));
end

mu = mean(spindenv_pk(:,gs),2);
s = std(spindenv_pk(:,gs),[],2);
spindenv_pk = (spindenv_pk-mu) ./ s;
sc = 2;

mu = mean(spindenv_ss(:,gs),2);
s = std(spindenv_ss(:,gs),[],2);
spindenv_ss = (spindenv_ss-mu) ./ s;

%spindenv_ss = spindenv_pk;

tmu = mean(theta.trial{1}(:,gs),2);
ts = std(theta.trial{1}(:,gs),[],2);
tz = (theta.trial{1}-tmu)./ts;

bmu = mean(beta.trial{1}(:,gs),2);
bs = std(beta.trial{1}(:,gs),[],2);
bz = (beta.trial{1}-bmu)./bs;

for k = 1 : size(lfp.trial{1},1)
    br=[];
    [pks,pkinds] = findpeaks(spindenv_pk(k,:));
    [~,rawpks] = findpeaks(spind.trial{1}(k,:));
    pkinds(pks < sc) = [];
    pks(pks < sc) = [];
    pkinds = intersect( gs, pkinds);
    if isempty(pkinds)
        st{k} = [];
        continue
    end
    %loop thru all spindles
    spinds = zeros(length(pkinds),2);
    bad_spind = zeros(1,length(pkinds));
    cross_long=zeros(length(pkinds),1);
    three_pk=zeros(length(pkinds),1);
    lenrej=zeros(length(pkinds),1);
    tb=zeros(length(pkinds),1);
    for kk = 1 : length(pkinds)
        %find 50% of max amplitude
        ph = .8;%pks(kk) ./ 2;
        cross_half = crossing(spindenv_pk(k,:),[],ph);
        cross_half = cross_half - pkinds(kk);
        [s_start] = max(cross_half(cross_half<0)); [s_end] = min(cross_half(cross_half>0));
        s_start = s_start + pkinds(kk); s_end = s_end + pkinds(kk);
        spind_inds = s_start:s_end;
        s = spind.trial{1}(k,spind_inds);
        scr = lfpf.trial{1}(k,spind_inds);
        if isempty(s)
            bad_spind(kk) = 1;
            continue
        end
        spinds(kk,1) = s_start; spinds(kk,2) = s_end;
%         reject if 
%         1. less than 250ms
        lenrej(kk) = length(s)<250; 
%         2. at least 3 peaks in signal
        three_pk(kk) = length(intersect(spind_inds,rawpks))<3;
%         3. each zero crossing within 30-110 ms
        halfcross=crossing(scr);%,[],0);
        crd = diff(halfcross);
        cross_long(kk) = mean(abs(crd-70)>40)>.1;
        %4. see if too much theta or beta power
        t = max(tz(k,spind_inds));
        b = max(bz(k,spind_inds));
        tb(kk) = (t>=4) + (b>=4);
        if three_pk(kk) || lenrej(kk) || tb(kk)%cross_long(kk) || three_pk(kk) || lenrej(kk) || tb(kk)
            bad_spind(kk) = 1;
        end
    end
    tb(tb>=1)=1;
    br = [cross_long three_pk lenrej tb];
    %get rid of bad spindles
    spinds(find(bad_spind),:) = [];
    sdstart = spinds(2:end,1); sdend = spinds(1:(end-1),2);
    td = sdstart - sdend; td = find(td<30); spinds(td,2) = spinds((td+1),2);
    spinds((td+1),:) = [];
    %spinds(:,td
    st{k} = spinds;
    spr{k} = br;
    disp(k)
end