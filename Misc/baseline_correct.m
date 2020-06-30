function a = baseline_correct(a,bl)
 
%normalizes response of a channel x time matrix by specified baseline
%indices

 mu = squeeze(nanmean(a(:,bl),2));
 std = squeeze(nanstd(a(:,bl),[],2));
 
 a = (a - repmat(mu,[1 size(a,2)])) ./ repmat(std,[1 size(a,2)]);