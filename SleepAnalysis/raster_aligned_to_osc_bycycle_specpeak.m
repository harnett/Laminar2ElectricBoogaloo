function [avglfp,rast_singtrial,rast_avgmean,rast_avgstd] = raster_aligned_to_osc_bycycle_specpeak(unitdata,tc,st,trgh_times,fs,pk)
%win in seconds
rmpath(genpath('C:\Users\Loomis\Documents\Packages\mvgc_v1.0'))

ti=[];
for k = 1 : size(st,1)
st_samp = [st(k,1):st(k,2)];
trgh_inds = intersect(st_samp,trgh_times);
trgh_inds = sort(trgh_inds); 
if length(trgh_inds) < pk
continue
else
    ti = [ti trgh_inds(pk)];
end
end

trldf = zeros(length(ti),3); trldf(:,1) = ti-500; trldf(:,2) = ti+500;

for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end
addpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
[dn,~] = binspikes(spk,fs);

fspk = tc; fspk.trial{1}=dn';
td = length(fspk.time{1})-length(fspk.trial{1});
fspk.trial{1} = [fspk.trial{1} zeros(length(unitdata), td)];
fspk=rmfield(fspk,'label');
for k = 1 : length(unitdata)
fspk.label{k}=num2str(k);
end

%[avg,trldf] = osc_avg(lfp,win,refch,[fqs(fq,1) fqs(fq,2)],gs,maxpk);
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
cfg=[]; cfg.trl=trldf; tc = ft_redefinetrial(cfg,tc);
cfg=[]; cfg.keeptrials='yes'; avg=ft_timelockanalysis(cfg,tc);
avglfp = avg;
end

%LineFormat = struct(); LineFormat.LineWidth = 1;
%plotSpikeRaster(squeeze(s(15,:,:))','plottype','vertline','LineFormat',LineFormat)