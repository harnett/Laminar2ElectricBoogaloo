function [xc_real,xc_z,lg] = spk_xcorr_stat(x,num_jitt,maxlag)
%performs statistics on cross-correlations of continuous epochs
%(as in Peyrache PNAS 2012)
%assumes spikes in 1 ms bins
%adds 10 ms std jitter
% initialize big time x unit matrix of zeros
% used for cross correlations

xc_real=zeros(size(x,2),size(x,2),(maxlag*2)+1);

for s = 1 : size(x,2)
    for s2 = s : size(x,2)
        [xc_real_tmp,lg] = xcorr(x(:,s),x(:,s2),maxlag);
        xc_real(s,s2,:) = xc_real_tmp;
    end
end

spk = x;
zcorr = zeros(size(x,2),size(x,2),(maxlag*2)+1,num_jitt);
% for each spike...
for s = 1 : size(spk,2)
    st = find(x(:,s));
    % for each jitter...
    for jit = 1 : num_jitt
        % jitter spike times for that spike only
        % make spike times 1 in that initial matrix
        stj = st + round(normrnd(0,10,[length(st) 1]));
        spk(:,s) = 0; spk(stj,s) = 1;
        % calc cross-corrs across all unit pairs with that unit jittered
        for s2 = s : size(spk,2)
        [xc] = xcorr(spk(:,s),spk(:,s2),maxlag,'unbiased');
        % put xcorr matrix in big 3d matrix for later z score
        zcorr(s,s2,:,jit) = xc;
        end
    end
    spk = x;
    disp(s)
end

% when loop done, get mu and std at each lag for each pair
% then z-score real xcorr matrix
xc_mu = nanmean(zcorr,4); xc_std = nanstd(zcorr,[],4);

xc_z = (xc_real - xc_mu) ./ xc_std;

end