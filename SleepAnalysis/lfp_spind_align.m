function [spnd_aligned_cent,spnd_aligned_strt,ts] = lfp_spind_align(lfp,st,tr)

%input: spindle samples st, trough times tr, raw time series lfp

Fs = 1000;
% make NaN matrix with # of rows equal to # of spindles
% column is time relative to spindle center
spnd_aligned_cent = NaN(size(st,1),3*Fs); cent_ind = round(size(spnd_aligned_cent,2)./2);
spnd_aligned_strt = spnd_aligned_cent;
% for each spindle, fill nan matrix with spindle aligned to peak closest to
% spindle center
ts=[];
for k = 1 : size(st,1)
    samp = st(k,1):st(k,2); %sample corresponding to this spindle
    spnd = lfp(samp); %lfp of this spindle
    spnd_tr = intersect(tr,samp); %find troughs in this spindle burst
    [~,tr_align] = min( abs( spnd_tr - median(samp))); %find index of middle trough of spindle
    tr_align = spnd_tr(tr_align);
    %find diff in spindle length vs. averaging window
    strt_ind = cent_ind - ( tr_align - spnd_tr(1) ); end_ind = cent_ind + ( spnd_tr(end) - tr_align );
    spnd_aligned_cent(k,strt_ind:end_ind) = spnd;
    spnd_aligned_strt(k,1:length(spnd)) = spnd;
    ts(k) = tr_align;
end

end