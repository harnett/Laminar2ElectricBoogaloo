function data2 = LFP_Bi_ChanDownsamp_Mean_DualLam(data,nch)
%LFP downsampler

lam1 = data.trial{1}(1:64,:);
x1 = zeros(nch,size(lam1,2));
for k = 1 : nch
x1(k,:) = mean(lam1( ...
    ( (1 + (k-1) * floor(size(lam1,1)./nch)) : (k * floor(size(lam1,1)./nch)) ) , :));
end

x1 = diff(x1);

lam2 = data.trial{1}(65:128,:);
x2 = zeros(nch,size(lam2,2));
for k = 1 : nch
x2(k,:) = mean(lam2( ...
    ( (1 + (k-1) * floor(size(lam2,1)./nch)) : (k * floor(size(lam2,1)./nch)) ) , :));
end

x2 = diff(x2);

cfg=[]; cfg.channel=data.label(1:(2*nch-2)); data2=ft_preprocessing(cfg,data);
data2.trial{1} = [x1; x2];