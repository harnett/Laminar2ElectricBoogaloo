function [ya,fx] = fft_trl(lfp,pCh)

% if isempty(pCh)
%     pCh = 1 : length(lfp.label);
% end

%returns ffts of each trial of an LFP file with the same frequency axis.

fx = linspace(0,500,1000);

ya=[];
for k = 1 : length(lfp.trial)
f = fft(lfp.trial{k}')'; f = f(:,1:round(length(f)/2)); f = f.*conj(f); 
y = [];
for kk = 1 : size(f,1)
y(kk,:) = interp1(linspace(min(fx),max(fx),length(f)),f(kk,:),fx);
end

ya = cat(3,ya,y);

end

y = squeeze(nanmean(ya,3));

%spind_rat = mean(y(:,16:38),2) ./ mean(y(:,3:9),2); [~,spind_maxchan] = max(spind_rat);

if ~isempty(pCh)
[p,~] = numSubplots(length(pCh));

for k = 1 : length(pCh)
subplot(p(1),p(2),k)
shadedErrorBar(fx,y(k,:),squeeze(std(ya(k,:,:),[],3))./sqrt(size(ya,3)));
xlim([.5 35])

end
end
end