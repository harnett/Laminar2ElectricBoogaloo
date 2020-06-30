function [roc u all_roc] = rocM(x2, x1,shuff)
%
%[roc] = rocM(x2, x1)
%
%Returns area under roc curve given distributions x1 and x2. Let x2 =
%failed and x1 = correct trial distributions to calculate DP or let x2 =
%pre-stim and x1 = post-stim distributions to calculate neurometric.
%

if shuff == 0

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
    
else
    
    x1 = x1(~isnan(x1));
    x2 = x2(~isnan(x2));
    
    k = 3; % how many folds 
    N = numel(x1) ; % this is the total number of observations or rows (trials)
    N2 = numel(x2) ; % this is the total number of observations or rows (trials)

    indices_x1 = crossvalind('Kfold',N,k); % divide test set into k random subsets
    indices_x2 = crossvalind('Kfold',N2,k); % divide test set into k random subsets
    combos = combvec(1:k,1:k);
    combos = combos(:,2:end-1); combos = [combos(:,1:3),combos(:,5:7)];
    
    for i2 = 1:size(combos,2)
                 
               x11 = x1(indices_x1 == combos(1,i2) | indices_x1 == combos(2,i2));
               x22 = x2(indices_x2 == combos(1,i2) | indices_x2 == combos(2,i2));


                % tricky part to find duplicates in each distribution
                [n1, b1] = myunique(x11(:),1);
                [n2, b2] = myunique(x22(:),1);

                %union calls unique in the background. But the rows are guaranteed to
                %be unique, so you can just sort the rows instead. There's a tiny bit
                %of overhead in sortrows though so I emulated sortrows below
                u = [[-inf 0 0] ; ...
                    [b1 [n1(1) ; diff(n1)]/length(x11) zeros(size(b1)); ...
                     b2 zeros(size(b2)) [n2(1) ; diff(n2)]/length(x22)]];
                [ignore idx] = sort(u(:,1));
                u = u(idx,:);

                % find duplicates across both distributions
                i = myunique(u(:,1),0);
                u = cumsum(u(:,[2 3]), 1);
                u = u(i, :);

                % uu is list of unique points (ie union(x1 and x2)) and u is the corresponding
                % cdf at x for each distribution
                all_roc(1,i2) = trapz(u(:,1), u(:,2)); % integrate roc curve with trapezoid rule
                
                clear x11 x22
    end

    roc = nanmean(all_roc);
    
end


    
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