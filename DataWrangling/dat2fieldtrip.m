function data = dat2fieldtrip(dat,fs)
%takes dat (chanxtimextrial) matrix and fs (sample rate) 
%and gives you fieldtrip data structure
sampind = 1;

for k = 1 : size(dat,3)
data.trial{k} = squeeze(dat(:,:,k));
data.time{k}=(1/fs):(1/fs):(length(data.trial{k})/fs);
data.sampleinfo(k,:)=[sampind sampind+length(data.trial{k})-1];
sampind = sampind + length(data.trial{k});
end
for k = 1 : size(dat,1)
    data.label{k} = num2str(k);
end