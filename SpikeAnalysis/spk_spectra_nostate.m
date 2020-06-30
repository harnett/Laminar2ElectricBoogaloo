function spctra = spk_spectra_nostate(unitdata)
for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end
[dn,~] = binspikes(spk,1000);
dn=cont_to_segment(dn,4000);
params.Fs = 1000; %params.err=2; 
params.trialave = 1; params.tapers = [3 5];
[S,f,R]=mtspectrumpb(squeeze(dn(:,1,:)),params);
spctra.S = nan(size(dn,2),length(S));
for kk = 1 : size(dn,2)
[S,f,R]=mtspectrumpb(squeeze(dn(:,kk,:)),params);
spctra.S(kk,:) = S; spctra.f = f; spctra.R(kk) = R; %spctra(k).Serr = Serr;
end

end
