function data = LFP_Spk_Concatenator(data,spk)
%takes fieldtrip LFP strcuture data and matrix of spikes spk to make
%one fieldtrip data structure with spikes and LFPs
%spk is samps x units

if length(spk)<length(data.trial{1})
    spk = [spk; zeros( length(data.trial{1}) - length(spk) , size(spk,2))];
elseif length(spk)>length(data.trial{1})
    error('spike matrix is longer than data matrix')
end

data.trial{1} = [data.trial{1}; spk'];

nLfpChs = length(data.label);

for k = 1 : size(spk,2)
    data.label{k + nLfpChs} = ['u' num2str(k)];
end

end