function [rl,xc_z,xc_std,mu_shff,std_shff] = xcorrTimestampShuff_OLD(x, y,nPrm)
diffs = [];
for i = 1:length(x)
    diffs = [diffs, y-x(i)];
end
diffs=diffs(abs(diffs)<=.025);
rl = histcounts(diffs,-.025:.0005:.025);
%bin it

diffs_shuff = zeros(nPrm,length(rl));
clear diffs
for prm = 1 : nPrm
    y = y + round(normrnd(0,.01,[length(y) 1]));
    diffs=[];
for i = 1:length(x)
    diffs = [diffs; y-x(i)];
    diffs=diffs(abs(diffs)<=.025);
end
diffs_shuff(prm,:) = histcounts(diffs,-.025:.0005:.025);
disp(prm./nPrm)
end

mu_shff = nanmean(diffs_shuff);
std_shff = nanstd(diffs_shuff);

xc_z = (rl - mu_shff) ./ std_shff;

xc_std = nanstd(diffs_shuff);

end