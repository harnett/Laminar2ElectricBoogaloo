function data2 = LFP_ChanDownsamp_Mean_DualLam_onlyPFC(data,nch)
%LFP downsampler

lam1 = data.trial{1}(1:64,:);
x1 = zeros(nch,size(lam1,2));
for k = 1 : nch
x1(k,:) = mean(lam1( ...
    ( (1 + (k-1) * floor(size(lam1,1)./nch)) : (k * floor(size(lam1,1)./nch)) ) , :));
end

cfg=[]; cfg.channel=data.label(1:nch); data2=ft_preprocessing(cfg,data);

data2.trial{1} = x1;

end