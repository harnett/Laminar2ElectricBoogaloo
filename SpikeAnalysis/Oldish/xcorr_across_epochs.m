function [xc_mu,xc_std,lg] = xcorr_across_epochs(spk,maxlag)

xc = zeros((maxlag*2)+1,size(spk,2).^2,size(spk,3));

%loop thru trials / epochs
for tr = 1 : size(spk,3)
    [xc_tmp,lg] = xcorr(spk(:,:,tr),maxlag,'unbiased');
    xc(:,:,tr) = xc_tmp;
    %disp(tr)
end

%get mean and var of cross-correlation
xc_mu = nanmean(xc,3);
xc_std = nanstd(xc,[],3);

end