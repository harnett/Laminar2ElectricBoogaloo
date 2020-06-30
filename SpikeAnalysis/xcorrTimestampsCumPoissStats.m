function [cch_prob, sigflag] = xcorrTimestampsCumPoissStats(cch_rl, cch_pred, win) 

if isempty(win)
win = (-.050:.0005:.050)+.00025;
end

cch_prob = zeros(size(cch_rl,1),size(cch_rl,2),size(cch_rl,3));

sigflag = zeros(size(cch_rl,1),size(cch_rl,1));

[~,li] = min(abs(win-.001));
[~,ui] = min(abs(win-.01));

%arrayfun

cch_prob = 1 - poisscdf(cch_rl,cch_pred);

for k = 1 : size(cch_rl,1)
    tmp0 = squeeze(cch_prob(k,:,li:ui));
    for kk = 1 : size(cch_rl,2)
%         for kkk = 1 : size(cch_rl,3)
%             tmp = 0:(cch_rl(k,kk,kkk)-1);
%             px = 1-sum((exp(-cch_pred(k,kk,kkk)).*(cch_pred(k,kk,kkk).^tmp)) ./ factorial(tmp));
%             cch_prob(k,kk,kkk) = px;
%         end
        tmp = tmp0(kk,:);
        tmp2 = zeros(1,length(tmp));
        tmp2(tmp<=.001) = 1;
        if max(tmp2)==1
            %find contiguous blocks of X within 1.5-4ms away from 0
            runs = contiguous(tmp2,1); runs=runs{1,2}; runs=runs(:,2)-runs(:,1);
            %if found, set sigflag to 1
            if max(runs)>=2 && max(cch_rl(k,kk,:)) >= 10
            sigflag(k,kk) = 1;
            end
        end
    end
    disp(k)
end