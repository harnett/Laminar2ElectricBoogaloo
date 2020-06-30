function [roc u] = rocM(x2, x1)
%
%[roc] = rocM(x2, x1)
%
%Returns area under roc curve given distributions x1 and x2. Let x2 =
%failed and x1 = correct trial distributions to calculate DP or let x2 =
%pre-stim and x1 = post-stim distributions to calculate neurometric.
%

     x1 = x1(~isnan(x1));
     x2 = x2(~isnan(x2));

    % tricky part to find duplicates in each distribution
    [n1, b1] = myunique(x1(:),1);
    [n2, b2] = myunique(x2(:),1);
       
    %union calls unique in the background. But the rows are guaranteed to
    %be unique, so you can just sort the rows instead. There's a tiny bit
    %of overhead in sortrows though so I emulated sortrows below
    u = [[-inf 0 0] ; ...
        [b1 [n1(1) ; diff(n1)]/length(x1) zeros(size(b1)); ...
         b2 zeros(size(b2)) [n2(1) ; diff(n2)]/length(x2)]];
    [ignore idx] = sort(u(:,1));
    u = u(idx,:);
    
    % find duplicates across both distributions
    i = myunique(u(:,1),0);
    u = cumsum(u(:,[2 3]), 1);
    u = u(i, :);
    
    % uu is list of unique points (ie union(x1 and x2)) and u is the corresponding
    % cdf at x for each distribution
    roc = trapz(u(:,1), u(:,2)); % integrate roc curve with trapezoid rule
end

%Here's the trick: unique performs a sort in the background (for N < 1000)
%or checks whether the vector is sorted. This is redundant since we were
%already doing a sort, so we know it is sorted. Now all we need is to make the
%indices returned be based on the sorted vector. Done.
function [n, x] = myunique(a,dosort)
    if dosort
        a = sort(a);
    end
    idx = diff(a) ~= 0;
    n = [find(idx); length(a)];
    
    if nargout > 1
        x = a(n);
    end
end