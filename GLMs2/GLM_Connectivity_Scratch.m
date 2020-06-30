clear
nb = 5;

load('glm_prelim_state1')
wxas = wxa;
gus=gu;
% hist(w,100000)
% plot(sort(w))

wxas(find(abs(wxas)>4))=nan;

ws = squeeze(nanmean(wxas(:,1:nb,:),2));
for k = 1 : size(ws,1)
    ws(k,k) = nan;
end
imagesc(ws,[-1 1]), axis square

ws = (ws-nanmean(ws(:)))./nanstd(ws(:));

load('glm_prelim_state2')
wxar=wxa;
gur=gu;

% hist(w,100000)
% plot(sort(w))

wxar(find(abs(wxar)>4))=nan;

wr = squeeze(nanmean(wxar(:,1:nb,:),2));
for k = 1 : size(wr,1)
    wr(k,k) = nan;
end
wr = (wr-nanmean(wr(:)))./nanstd(wr(:));
figure, imagesc(wr,[-1 1]), axis square

[sharedvals,idx] = intersect(gus,gur,'stable');
ws = ws(idx,idx); wxas = wxas(idx,:,idx);
figure, imagesc(ws-wr,[-3 3]), axis equal

figure, plot(squeeze(wxas(36,:,34))), hold on, plot(squeeze(wxar(36,:,34)))
%%
clear
nb = 5;

load('glm_prelim_state1')
% hist(w,100000)
% plot(sort(w))

wxa(find(abs(wxa)>4))=nan;

w = squeeze(nanmean(wxa(:,1:nb,:),2));
for k = 1 : size(w,1)
    w(k,k) = nan;
end
%imagesc(w,[-1 1]), axis square

wc = nanmean(w(:)) + 1.5*nanstd(w(:));
wconn = w; wconn(wconn<wc) = nan; wconn(~isnan(wconn)) = 1;
figure, imagesc(wconn)
wbi = wconn + wconn';
wbi(wbi~=2) = nan;
figure, imagesc(wbi)

clear ra
for k = 53:101
seg = [k-2 k+2];
rconn = wbi(seg(1):seg(2),51:end);
rconn = (length(find(rconn==2))/2)/(numel(rconn)-(seg(2)-seg(1)+1));
ra(k-52) = rconn;
end