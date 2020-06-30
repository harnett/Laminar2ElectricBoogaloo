function [xc_real,xc_z,xc_std,mushff,stdshff] = xcorr_segment_avg(u,nlg,tlen,nPrm)

u = cont_to_segment(u,tlen);
%u is chsxtimextrial
xcorrs = zeros(2*nlg+1,size(u,2)*size(u,2),size(u,3));
for k = 1 : size(u,3)
    xcorrs(:,:,k) = xcorr(squeeze(u(:,:,k)),nlg);
end

xcorrs_shuff = zeros(2*nlg+1,size(u,2)*size(u,2),nPrm);
for prm = 1 : nPrm
    for kk = 1 : size(u,1)
        u(kk,:,:) = u(kk,:,randperm(size(u,3)));
    end
    xcorrs_shuff_tmp = zeros(2*nlg+1,size(u,2)*size(u,2),size(u,3));
    for k = 1 : size(u,3)
        xcorrs_shuff_tmp(:,:,k) = xcorr(u(:,:,k),nlg);
    end
    xcorrs_shuff(:,:,prm) = squeeze(nanmean(xcorrs_shuff_tmp,3));
    disp(prm)
end

mushff = nanmean(xcorrs_shuff,3);
stdshff = nanstd(xcorrs_shuff,[],3);
xc_real=nanmean(xcorrs,3);
xc_std = nanstd(xcorrs,[],3);
xc_z = (xc_real-mushff)./stdshff;
end