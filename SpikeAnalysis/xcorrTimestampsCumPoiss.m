function [cch_rl,cch_pred,cch_prob,sigflag] = xcorrTimestampsCumPoiss(unitdata,win,toilim,gs)

%unitdata is a structure in which each element is a unit. unitdata(n).ts
%should have the spike times of the nth unit in seconds.

%win is a vector which has the time-axis you want for the resultant xcorrs (in seconds).
%if you want to show the xcorr with +-10 seconds with 50 ms resolution, win
%= -10:.05:10

%toilim OR gs (not both) should be used. Either describes which timeperiods
%should be used for computing xcorrs. toilim is a 2 element vector with 2 times in seconds, and
%tells the function to only use spikes between those 2 times (say 300 and
%450 seconds). gs ('good samples') lets you input a vector of samples which
%xcorrs should be computed on. so, gs = [2 3 4 5] would only analyze spikes
%in samples 2-5. use one or the other, not both.

%toilim in seconds
if isempty(win)
win = (-.050:.0005:.050)+.00025;
end

wlen = 10000;
a =  (wlen - 1) / (2 * (.007/mean(diff(win))) );

w = gausswin(wlen,a); % we want sig to be 7 ms (14 bins), sig = (L-1)/(2a), so a = (L-1)/(2*sig) = 499/(2*14) = 17.82
w=w./sum(w);
%alpha = (len - 1) / (2*stdev)
% initialize real cross-corrs

%cch_rl = zeros(length(unitdata),length(unitdata),length(win));
cch_rl = nan(length(unitdata),length(unitdata),length(win)-1);
cch_pred = cch_rl;

%tmpt = vertcat(unitdata(:).ts); tmpt = tmpt(:);

if ~isempty(toilim)
for k = 1 : length(unitdata)
    tsa{k} = unitdata(k).ts(intersect(find(unitdata(k).ts<=toilim(2)),find(unitdata(k).ts>=toilim(1))));% MARIE FOUND BUG tsa{k} = intersect(find(unitdata(k).ts<=toilim(2)),find(unitdata(k).ts>=toilim(1)));
end
elseif ~isempty(gs)
for k = 1 : length(unitdata)
    ts_ms = round(unitdata(k).ts.*1000); [~,~,gts] = intersect(gs,ts_ms);
    tsa{k} = (unitdata(k).ts(gts));
end
else
for k = 1 : length(unitdata)
    tsa{k} = (unitdata(k).ts);
end
end

% compute raw xcorrs
for k = 1 : length(unitdata)
    tic
    parfor kk = k : length(unitdata)
        [tmp,tmp2] = xcorrsubfun(tsa,win,w,k,kk);
        cch_rl(k,kk,:) = tmp;
        % convolve with gaussian to get predictor cch
        
        %tmp2 = convnfft(tmp,w,'same');%filter(w,1,diffs);
        
        cch_pred(k,kk,:) = tmp2;
    end
    toc
    disp(k)
end

for kk = 2 : (length(unitdata)-1)
    for k = 1 : ( kk - 1)
        cch_rl(kk,k,:) = fliplr(squeeze(cch_rl(k,kk,:))');
        cch_pred(kk,k,:) = fliplr(squeeze(cch_pred(k,kk,:))');
    end
end
        
% calculate using formula from Stark Abeles 2009
% preemptively calculate matrix with cumulative distribution at each
% element???
% use loop (for now) to apply to each element)

[cch_prob, sigflag] = xcorrTimestampsCumPoissStats(cch_rl, cch_pred, win);

%save('XCorrOut.mat','cch_rl','cch_pred','cch_prob','sigflag')

end

function [tmp, tmp2] = xcorrsubfun(tsa,win,w,k,kk)
    ts1 = tsa{k}; ts2 = tsa{kk};
    diffs = xcorrTimestamps(ts1,ts2);
    %diffs = xcorrTimestamps_Old(unitdata(k).ts,unitdata(kk).ts);
    %diffs(abs(diffs)>=max(win))=[];
    tmp = histcounts(diffs,win); 

    % convolve with gaussian to get predictor cch
        
    tmp2 = conv(tmp,w,'same');%filter(w,1,diffs);
end