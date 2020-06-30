function [avglfp,rast_singtrial,rast_avgmean,rast_avgstd] = raster_aligned_to_spind(unitdata,lfp,gs,win,fs,refch,fqs,maxpk)
%win in seconds
rmpath(genpath('C:\Users\Loomis\Documents\Packages\mvgc_v1.0'))


for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end
addpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
[dn,~] = binspikes(spk,fs,[(1./fs) length(lfp.time{1})./fs]);

fspk = lfp; fspk.trial{1}=dn';
td = length(fspk.time{1})-length(fspk.trial{1});
fspk.trial{1} = [fspk.trial{1} zeros(length(unitdata), td)];
fspk=rmfield(fspk,'label');
for k = 1 : length(unitdata)
fspk.label{k}=num2str(k);
end

[avg,trldf] = osc_avg(lfp,win,refch,fqs,gs,maxpk);
trldf(:,1:2)=trldf(:,1:2)-td;
cfg=[]; cfg.trl=trldf; fspk2 = ft_redefinetrial(cfg,fspk);
s = fieldtrip2mat_epochs(fspk2);

s2 = s;
for k = 1 : size(s,1)
for kk = 1 : size(s,3)
s2(k,:,kk) = smooth(squeeze(s(k,:,kk)),10);
end
end
s2 = s2.*100;
s2s = nanstd(s2,[],3);
s2m = nanmean(s2,3);


rast_singtrial = s;
rast_avgmean = s2m;
rast_avgstd = s2s;
avglfp = avg.avg;
end