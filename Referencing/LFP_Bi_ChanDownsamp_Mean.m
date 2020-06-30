function data2 = LFP_Bi_ChanDownsamp_Mean(data,nch)
%LFP downsampler

x = zeros(nch,length(data.trial{1}));
for k = 1 : nch
x(k,:) = mean(data.trial{1}( ...
    ( (1 + (k-1) * floor(size(data.trial{1},1)./nch)) : (k * floor(size(data.trial{1},1)./nch)) ) , :));
end
x = diff(x);
cfg=[]; cfg.channel=data.label(1:(nch-1)); data2=ft_preprocessing(cfg,data);
data2.trial{1} = x;