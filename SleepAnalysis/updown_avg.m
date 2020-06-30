function [lfp,ds] = updown_avg(lfp,unitdata,states)
% used to return dsm
s = time_STATE2gs(states(1).t);

addpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end
[dn,~] = binspikes(spk,1000); dn = dn'; dn(dn>1) = 1; dn = dn.*500;
if length(dn) < length(lfp.trial{1})
dn = [dn zeros(size(dn,1),length(lfp.trial{1})-length(dn))];
end

mean_fr=smooth(mean(dn),50);

% for k = 1 : size(dn,1)
% dn(k,:) = smooth(dn(k,:),20);
% end

if length(dn) < length(lfp.trial{1})
dn = [dn zeros(size(dn,1),length(lfp.trial{1})-length(dn))];
end
nLfpCh = size(lfp.trial{1},1);
for k = 1 : size(dn,1)
    lfp.label{k+nLfpCh} = ['unit' num2str(k)];
end
lfp.trial{1} = [lfp.trial{1}; dn./500];
% for k = 1 : size(dn,1)
%     dn(k,:) = smooth(dn(k,:),20);
% end
%mean_fr = mean(dn).*100;


ds = mean_fr<=.8;
ds = contiguous(ds);
ds=ds{2,2};
d=diff(ds,[],2);
ds=ds((d>=100),:);

dsm = round(mean(ds,2));

ds_end = ds(:,2); %SELECTS WHETHER DOWN-UP OR UP-DOWN

ds_end = intersect(s,ds_end);

trldf = zeros(size(ds_end,1),3); trldf(:,1) = ds_end - 100; trldf(:,2) = ds_end+100;
cfg=[]; cfg.trl=trldf; lfp = ft_redefinetrial(cfg,lfp);