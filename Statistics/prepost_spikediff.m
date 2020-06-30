function [pre,post,pv] = prepost_spikediff(spk,prel,postl)

x = fieldtrip2mat_epochs(spk);

pre = squeeze(x(:,prel(1):prel(2),:)); pre = squeeze(mean(pre,2));

post = squeeze(x(:,postl(1):postl(2),:)); post = squeeze(mean(post,2));

for k = 1 : size(pre,1)
pv(k) = signrank(pre(k,:),post(k,:));
end

end