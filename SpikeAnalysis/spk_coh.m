function spkcoh = spk_coh(unitdata,states,fs)
%unitdata: structure where each element .ts contains spike times in seconds
% i.e., unitdata(1).ts has the spike times (in seconds) for unit 1
%states: structure where each element .t has times (in samples) for
%different behavioral states (subsets of data) to analyze.
% so, if states(1).t = [3 4 5], and states(2).t = [6 7 8], running
% this function would give you the spike spectra/coherencies for 
% spikes occuring during samples [3 4 5] and [6 7 8] separately. 
% Might be useful if you want to contrast sleep vs wake or spindle vs
% non-spindle.
% fs: sample rate (in hz)
% spkcoh: outputs as in coherencgmysegpb. C is coherencies, S1 and S2 are
% spectra.
%dependencies: chronux toolbox
addpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
params.Fs=fs;
params.tapers = [3 5];

for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end

for s = 1 %: length(states) %parfor

[dn,t] = binspikes(spk,fs);
%dn = [dn; zeros(max(gs)-length(dn),size(dn,2))]; % pad dn with zeros just in case lfp exceeds spikes
if ~isempty(states)
gs=time_STATE2gs(states(s).t);
dn=dn(gs,:);
end

nUnit = size(dn,2);
[C]=coherencysegpb(dn(:,1),dn(:,2),4,params);
C_all = zeros(nUnit,nUnit,length(C));
phi_all = C_all;
for k = 1 : nUnit
    tic
    for kk = k : nUnit
        [C,phi,S12,S1,S2,f,zerosp]=coherencysegpb(dn(:,k),dn(:,kk),4,params);
        C_all(k,kk,:) = C; phi_all(k,kk,:) = phi;
        C_all(kk,k,:) = C; phi_all(kk,k,:) = -phi;
    end
    toc
    disp(k)
end

spkcoh(s).C = C_all;
spkcoh(s).phi=phi_all;
spkcoh(s).S12=S12;
spkcoh(s).S1=S1;
spkcoh(s).S2=S2;
spkcoh(s).f=f;
spkcoh(s).zerosp=zerosp;
end

end