function diffs = xcorrTimestamps(x, y)
% y=repmat(y,[1 length(x)]);
% x=x'; x=repmat(x,[size(y,1) 1]);
% 
% diffs = y-x; diffs=diffs(:);

%diffs = zeros(1,length(x).*length(y));

%diffs = y - x'; diffs(abs(diffs)>.05)=[];

diffs = nan(1,500000);
ci=1;
for k = 1 : length(x)
    tmp=y-x(k); tmp(abs(tmp)>.05) = [];
    diffs( ci : (ci+length(tmp)-1)) = tmp;
    ci = ci + length(tmp);
    %diffs = [diffs; tmp];
end
diffs = diffs(1:(ci-1));


end