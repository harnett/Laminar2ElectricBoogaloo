function lfp = LFP_SpkTS_Concatenator(unitdata,lfp,fs)

for u = 1 : length(unitdata)
    spk(u).time = unitdata(u).ts;
end

dn = binspikes(spk,fs); dn = dn';

dn = [dn zeros(size(dn,1),length(lfp.trial{1})-length(dn))];

lfp.trial{1} = [lfp.trial{1}; dn];

nLfpChs = length(lfp.label);

for k = 1 : size(spk,2)
    lfp.label{k + nLfpChs} = ['u' num2str(k)];
end

end