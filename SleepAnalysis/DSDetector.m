function allpks = DSDetector(lfp,mua_mn,gs,chs)

muathr = -.3;

% addpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
% for k = 1 : length(unitdata)
% spk(k).time = unitdata(k).ts;
% end
% [dn,~] = binspikes(spk,1000,[lfp.time{1}(1) lfp.time{1}(end)]); dn = dn';
rmpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
% DownState Detector

% filter in delta
cfg=[]; cfg.bpfilter='yes'; cfg.bpfreq=[.2 1.5]; cfg.bpinstabilityfix='reduce'; delta = ft_preprocessing(cfg,lfp);
% loop thru chs...
for ch = 1 : length(chs)
[pksa,pks] = findpeaks(-delta.trial{1}(chs(ch),:));
[pks,pksi] = intersect(pks,gs);
pksa = pksa(pksi); [~,pksas] = sort(pksa); pksas = pksas(round(.7*length(pksas)):end);
pks = pks(pksas);
pks(pks<200) = []; pks(pks>(length(delta.trial{1})-200)) = [];
% find Xth percentile of troughs by hilbert power
% sort pks by delta power
% set criteria for firing as well (< X?)
% take dn
% take mean firing, find firing in 100 ms band around oscillation
bpk = zeros(1,length(pks));
for kk = 1 : length(pks)
    if mean(mua_mn(ch,(pks(kk)-100):(pks(kk)+100))) >= muathr
        bpk(kk) = 1;
    end
end

disp(length(find(bpk))./length(bpk))

% only keep peaks with lower firing
pks(find(bpk)) = [];

allpks{ch} = pks;

end
end