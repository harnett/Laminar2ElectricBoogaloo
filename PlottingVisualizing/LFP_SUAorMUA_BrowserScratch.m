addpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
load('LFP_1k.mat')
load('UnitData.mat')
for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end
[dn,t] = binspikes(spk,1000); dn = dn'; dn(dn>1) = 1; dn = dn.*500;
if length(dn) < length(lfp.trial{1})
dn = [dn zeros(size(dn,1),length(lfp.trial{1})-length(dn))];
end
nLfpCh = size(lfp.trial{1},1);
for k = 1 : size(dn,1)
    lfp.label{k+nLfpCh} = ['unit' num2str(k)];
end
lfp.trial{1} = [lfp.trial{1}; dn];
for k = 1 : size(dn,1)
    dn(k,:) = smooth(dn(k,:),20);
end
lfp.trial{1}(32,:) = mean(dn).*100;
cfg=[]; cfg.viewmode='vertical'; cfg.blocksize=5; ft_databrowser(cfg,lfp)
%%
for k = 1 : length(mua.label)
mua.label{k} = [mua.label{k} 'm'];
end

cfg=[]; lfpmua = ft_appenddata(cfg,lfp,mua);

trldf = zeros(length(st),3); trldf(:,1) = st(:,1) - 700; trldf(:,2) = st(:,2) + 700;
trldf(trldf(:,1)<1,:) = []; trldf(trldf(:,2)>length(lfpmua.trial{1}),:) = [];
cfg=[]; cfg.trl=trldf; lfpmua = ft_redefinetrial(cfg,lfpmua);

%%
addpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
load('LFP_1k.mat')
load('UnitData.mat')
load('bycycle_spindledetect_out.mat')
for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end
[dn,t] = binspikes(spk,1000); dn = dn'; dn(dn>1) = 1; dn = dn.*500;
if length(dn) < length(lfp.trial{1})
dn = [dn zeros(size(dn,1),length(lfp.trial{1})-length(dn))];
end
nLfpCh = size(lfp.trial{1},1);
for k = 1 : size(dn,1)
    lfp.label{k+nLfpCh} = ['unit' num2str(k)];
end
lfp.trial{1} = [lfp.trial{1}; dn];
trldf = zeros(length(st),3); trldf(:,1) = st(:,1) - 700; trldf(:,2) = st(:,2) + 700;
trldf(trldf(:,1)<1,:) = []; trldf(trldf(:,2)>length(lfp.trial{1}),:) = [];
cfg=[]; cfg.trl=trldf; lfp = ft_redefinetrial(cfg,lfp);
cfg=[]; cfg.viewmode='vertical'; cfg.blocksize=5; ft_databrowser(cfg,lfp)