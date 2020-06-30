function [avglfp,rast_singtrial,rast_avgmean,rast_avgstd] = raster_aligned_to_osc(unitdata,lfp,states,win,fs,refch,fqs,maxpk)
%win in seconds
rmpath(genpath('C:\Users\Loomis\Documents\Packages\mvgc_v1.0'))


for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end
addpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
[dn,~] = binspikes(spk,fs);

fspk = lfp; fspk.trial{1}=dn';
td = length(fspk.time{1})-length(fspk.trial{1});
fspk.trial{1} = [fspk.trial{1} zeros(length(unitdata), td)];
fspk=rmfield(fspk,'label');
for k = 1 : length(unitdata)
fspk.label{k}=num2str(k);
end

for st = 1 : length(states)
    gs=time_STATE2gs(states(st).t);
    for fq = 1 : size(fqs,1)
[avg,trldf] = osc_avg(lfp,win,refch,[fqs(fq,1) fqs(fq,2)],gs,maxpk);
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


rast_singtrial{st,fq} = s;
rast_avgmean{st,fq} = s2m;
rast_avgstd{st,fq} = s2s;
avglfp{st,fq} = avg.avg;
disp([st fq])
    end

end
%LineFormat = struct(); LineFormat.LineWidth = 1;
%plotSpikeRaster(squeeze(s(15,:,:))','plottype','vertline','LineFormat',LineFormat)

end