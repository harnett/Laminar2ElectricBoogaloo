function lfp = LFP_Unit_View(lfp,unitdata,view_flag)
addpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
% load('LFP_1k.mat')
% load('UnitData.mat')
%load('bycycle_spindledetect_out.mat')
maxs=[];
for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts; maxs = [maxs max(spk(k).time)];
end
[dn,~] = binspikes(spk,lfp.fsample,[0 max(lfp.time{1})]); dn = dn'; dn(dn>1) = 1;

if length(dn) < length(lfp.trial{1})
dn = [dn zeros(size(dn,1),length(lfp.trial{1})-length(dn))];
end
if length(lfp.trial{1}) < length(dn)
dn = dn(:,1:(end-(length(dn)-length(lfp.trial{1}))));
end

nLfpCh = size(lfp.trial{1},1);
for k = 1 : size(dn,1)
    lfp.label{k+nLfpCh} = ['unit' num2str(k)];
end
lfp2 = lfp;
lfp2.trial{1} = [lfp.trial{1}; dn.*500];
lfp.trial{1} = [lfp.trial{1}; dn];
%trldf = zeros(length(st),3); trldf(:,1) = st(:,1) - 700; trldf(:,2) = st(:,2) + 700;
%trldf(trldf(:,1)<1,:) = []; trldf(trldf(:,2)>length(lfp.trial{1}),:) = [];
%cfg=[]; cfg.trl=trldf; lfp = ft_redefinetrial(cfg,lfp);
if view_flag
cfg=[]; cfg.viewmode='vertical'; cfg.blocksize=5; ft_databrowser(cfg,lfp2)
end
end