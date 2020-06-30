function [rl,xc_z,mu_shff,std_shff] = xcorrTimestampShuff(x, y,nPrm)
diffs = [];

y=repmat(y,[1 length(x)]);
x=x'; x=repmat(x,[size(y,1) 1]);

diffs = y-x; diffs=diffs(:);

diffs=diffs(abs(diffs)<=.01);
rl = histcounts(diffs,-.01:.0005:.01);
%bin it

diffs_shuff = zeros(nPrm,length(rl));
clear diffs
for prm = 1 : nPrm
    %y = y + repmat((normrnd(0,.01,[size(y,1) 1])),[1 size(y,2)]);
    y = y + normrnd(0,.01);
    diffs = y-x; diffs=diffs(:);
    diffs=diffs(abs(diffs)<=.01);
    diffs_shuff(prm,:) = histcounts(diffs,-.01:.0005:.01);
    %disp(prm./nPrm)
end

mu_shff = nanmean(diffs_shuff);
std_shff = nanstd(diffs_shuff);

xc_z = (rl - mu_shff) ./ std_shff;

end