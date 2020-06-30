function st = spindle_detector_Xi(lfp,gs)
rmpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
%filter signal 10-16
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[10 16]; spind = ft_preprocessing(cfg,lfp);
%get theta and beta amplitudes as well
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[4 8]; theta = ft_preprocessing(cfg,lfp);
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[17 25]; beta = ft_preprocessing(cfg,lfp);

%get analytic amplitude
cfg=[]; cfg.hilbert = 'abs'; spindenv = ft_preprocessing(cfg,spind);
%convolve with tukey window 600 ms
wpk=tukeywin(600); wss=tukeywin(400);
spindenv_pk = spindenv.trial{1}; spindenv_ss = spindenv_pk;
for k = 1 : size(spindenv_pk,1)
    spindenv_pk(k,:) = filtfilt(wpk,1,spindenv.trial{1}(k,:));
    spindenv_ss(k,:) = filtfilt(wss,1,spindenv.trial{1}(k,:));
end
%find local maxima, throw out all less than m + 2 SD
mu = mean(spindenv_pk(:,gs),2);
s = std(spindenv_pk(:,gs),[],2);
sc = mu + (1*s);

tmu = mean(theta.trial{1}(:,gs),2);
ts = std(theta.trial{1}(:,gs),[],2);
tz = (theta.trial{1}-tmu)./ts;

bmu = mean(beta.trial{1}(:,gs),2);
bs = std(beta.trial{1}(:,gs),[],2);
bz = (beta.trial{1}-bmu)./bs;

for k = 1 : size(lfp.trial{1},1)
    [pks,pkinds] = findpeaks(spindenv_pk(k,:));
    [~,rawpks] = findpeaks(spind.trial{1}(k,:));
    pkinds(pks < sc(k)) = [];
    pks(pks < sc(k)) = [];
    pkinds = intersect( gs, pkinds);
    if isempty(pkinds)
        st{k} = [];
        continue
    end
    %loop thru all spindles
    spinds = zeros(length(pkinds),2);
    bad_spind = zeros(1,length(pkinds));
    for kk = 1 : length(pkinds)
        %find 50% of max amplitude
        ph = pks(kk) ./ 2;
        cross_half = crossing(spindenv_ss(k,:),[],ph);
        cross_half = cross_half - pkinds(kk);
        [s_start] = max(cross_half(cross_half<0)); [s_end] = min(cross_half(cross_half>0));
        s_start = s_start + pkinds(kk); s_end = s_end + pkinds(kk);
        spind_inds = s_start:s_end;
        s = spind.trial{1}(k,spind_inds);
        if isempty(s)
            bad_spind(kk) = 1;
            continue
        end
        spinds(kk,1) = s_start; spinds(kk,2) = s_end;
%         reject if 
%         1. less than 400ms
        lenrej = length(s)<400; 
%         2. at least 3 peaks in signal
        three_pk = length(intersect(spind_inds,rawpks))<3;
%         3. each zero crossing within 40-100 ms
        halfcross=crossing(s,[],0);
        cd = diff(halfcross);
        cross_long = sum(abs(cd-70)>30);
        %4. see if too much theta or beta power
        t = max(tz(k,spind_inds));
        b = max(bz(k,spind_inds));
        tb = (t>=2.5) + (b>=2.5);
        if cross_long || three_pk || lenrej || tb
            bad_spind(kk) = 1;
        end
    end
    %get rid of bad spindles
    spinds(find(bad_spind),:) = [];
    st{k} = spinds;
    disp(k)
end