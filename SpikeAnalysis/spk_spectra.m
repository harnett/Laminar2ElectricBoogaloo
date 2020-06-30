function spctra = spk_spectra(unitdata,states)
for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end
for k = 1 : 3
gs=time_STATE2gs(states(k).t);
[dn,~] = binspikes(spk,1000);
dn = [dn; zeros(max(gs)-length(dn),size(dn,2))]; % pad dn with zeros just in case lfp exceeds spikes
dn=dn(gs,:);
dn=cont_to_segment(dn,4000);
params.Fs = 1000; %params.err=2; 
params.trialave = 1; params.tapers = [3 5];
[S,f,R]=mtspectrumpb(squeeze(dn(:,1,:)),params);
spctra(k).S = nan(size(dn,2),length(S));
for kk = 1 : size(dn,2)
[S,f,R]=mtspectrumpb(squeeze(dn(:,kk,:)),params);
spctra(k).S(kk,:) = S; spctra(k).f = f; spctra(k).R(kk) = R; %spctra(k).Serr = Serr;
end
disp(k)
end
end
