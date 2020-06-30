function [ns,r,rpv,rz,ang,cycle_len,fr,fr_all,ti_all] = bycycle_spike_analyses(unitdata,lfp,refch,st,trgh_times,fs,npk)

%get r-value for all of the nth value spikes across all cycles?
cfg=[]; cfg.channel = lfp.label(refch); lfp= ft_preprocessing(cfg,lfp);
cfg=[]; cfg.bpfilter='yes'; cfg.bpinstabilityfix='reduce'; cfg.bpfreq=[8.5 19]; lfp = ft_preprocessing(cfg,lfp);
cfg=[]; cfg.hilbert='angle'; phsdat = ft_preprocessing(cfg,lfp); phsdat = phsdat.trial{1};

%win in seconds
rmpath(genpath('C:\Users\Loomis\Documents\Packages\mvgc_v1.0'))

for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end

addpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
[dn,~] = binspikes(spk,fs); dn=dn'; dn(dn>1)=1;

ti_all={};
ns=nan(length(unitdata),size(st,1),npk);
r=nan(length(unitdata),npk); rpv = r; rz = r;
ang=nan(length(unitdata),npk);
cycle_len=nan(size(st,1),npk);

for pk = 1 : npk
    ti=[];
for k = 1 : size(st,1)
st_samp = [st(k,1):st(k,2)];
trgh_inds = intersect(st_samp,trgh_times);
trgh_inds = sort(trgh_inds); 
if length(trgh_inds) < (pk+1)
continue
else
    cycle_inds = trgh_inds(pk):trgh_inds(pk+1);
    cycle_len(k,pk) = length(cycle_inds);
    ns(:,k,pk) = sum(dn(:,cycle_inds),2);
    fr(:,k,pk) = ns(:,k,pk)./length(cycle_inds);
    ti = [ti trgh_inds(pk):trgh_inds(pk+1)];
end
end

for u = 1 : length(unitdata)
    spkg = intersect(ti,find(dn(u,:)));
    if ~isempty(spkg)
    fr_all(u,pk) = length(spkg) ./ length(ti);
    phstmp = phsdat(spkg);
    r(u,pk) = abs(mean(exp(1i.*phstmp),2));
    [pv,z] = circ_rtest(phstmp);
    rpv(u,pk) = pv;
    rz(u,pk) = z;
    ang(u,pk) = angle(mean(exp(1i.*phsdat(spkg)),2));
    end
end

ti_all{pk} = ti;
disp(pk)
end

end