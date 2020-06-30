function [xc_mu_rl,xc_std_rl,xc_z,xc_std_shff,lg] = xcorr_shff_across_epochs(spk,maxlag,num_shff)

[xc_mu_rl,xc_std_rl,lg] = xcorr_across_epochs(spk,maxlag);

xc_shff = zeros((2*maxlag)+1,size(spk,2)^2,num_shff);

for shff = 1 : num_shff
    
    prm = randperm(size(spk,3));
    
    [xc_tmp,~,lg] = xcorr_across_epochs(spk(:,:,prm),maxlag);
    
    xc_shff(:,:,shff) = xc_tmp;
    
    disp(shff)

end

xc_mu_shff = nanmean(xc_shff,3); xc_std_shff=nanstd(xc_shff,[],3);

xc_z = (xc_mu_rl - xc_mu_shff) ./ xc_std_shff;

end