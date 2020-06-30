clear
load('XCorr_ThalamoCort_AllState_All.mat')
xs = max(xca,[],2);
xca(xs<20,:) = []; aa(xs<20) = [];

zm = max(zscore(xca(:,[1:97 103:end]),[],2),[],2);
[~,zmi] = sort(zm);
xca=(flipud(xca(zmi,:)));


for k = 1 : 64
subplot(8,8,k)
plot(xca(k,:))
end