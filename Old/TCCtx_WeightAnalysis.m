clear

cd Y:\Milan\DriveDataSleep
load('spinddelt_cpling_glm_all_fin2.mat')

thctxa = (thctxa1+thctxa2)./2;
ctxtha = (ctxtha1+ctxtha2)./2;

subsictxth = subsi; subsithctx=subsi;

ctxtha(abs(ctxtha)>4)=nan; thctxa(abs(thctxa)>4)=nan;

ni = mean(ctxtha(:,4:7),2);
ni = find(isnan(ni));
ctxtha(ni,:) = [];

subsictxth(ni) = [];

ni = mean(thctxa(:,4:7),2);
ni = find(isnan(ni));
thctxa(ni,:) = [];

subsithctx(ni) = [];

for k = 1 : 6
subplot(2,3,k)
plot(nanmean(ctxtha(subsictxth==k,:))), hold on
plot(nanmean(thctxa(subsithctx==k,:))), hold on
end

tc_mgb = (thctxa(union(find(subsithctx==3),find(subsithctx==4)),:));

tc_md = (thctxa(union(find(subsithctx==5),find(subsithctx==6)),:));

for k = 1 : length(tc_md)
    pv(k) = ranksum(tc_mgb(:,k),tc_md(:,k));
end

shadedErrorBar(1:243,nanmean(tc_md),nanstd(tc_md)./sqrt(size(tc_md,1)),'LineProps',{'Color','b'}), hold on
shadedErrorBar(1:243,nanmean(tc_mgb),nanstd(tc_mgb)./sqrt(size(tc_mgb,1)),'LineProps',{'Color','r'})
hold on, plot(pv)