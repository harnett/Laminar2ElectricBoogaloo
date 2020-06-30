load('LFP_1k.mat')
load('UnitData.mat')
load('States.mat')

[lfp_avg,ds] = updown_avg(lfp,unitdata,states);
ds = [ds(1:(end-1),2) ds(2:end,1)];

for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end
[dn,~] = binspikes(spk,1000); dn = dn'; dn(dn>1) = 1;

w=gausswin(20); w=w./sum(w);
for k = 1 : size(dn,1)
    dn(k,:) = conv(dn(k,:),w,'same');
end
% 
% [coeff,score,latent,tsquared,explained,mu] = pca(dn'); 
% 
% c = cont_to_segment(score,201);

% red = [1, 0, 0];
% pink = [0 0 1];
% colors_p = [linspace(red(1),pink(1),101)', linspace(red(2),pink(2),101)', linspace(red(3),pink(3),101)'];

% for k = 1 : size(c,3)
% scatter3(c(1:101,1,k),c(1:101,2,k),c(1:101,3,k),10,colors_p)
% hold on
% end

dg = find(diff(ds,[],2)<400); ds = ds(dg,:);

z = {}; za = []; indi = 1; dinds={};
for k = 1 : size(ds,1)
    za = [za dn(:,ds(k,1):ds(k,2))];
    dinds{k} = [indi size(za,2)];
    indi = indi + (ds(k,2)-ds(k,1))+1;
end

% z = {}; za = [];
% for k = 1 : length(dg)
%     z{k} = dn(:,dsm(dg(k)):dsm(dg(k+1)));
%     za = [za dn(:,dsm(dg):dsm(dg+1))];
%     zlen(k) = (dg(k)+1) - dg(k) + 1;
% end

[coeff,score,latent,tsquared,explained,mu] = pca(za'); 

for k = 1 : length(dinds)
ts = dinds{k}(1):dinds{k}(2);
colors_p = jet(length(ts));
%colors_p = [linspace(red(1),pink(1),length(ts))', linspace(red(2),pink(2),length(ts))', linspace(red(3),pink(3),length(ts))'];
%scatter3(score(ts,1),score(ts,2),score(ts,3),2,colors_p), hold on% pause(3)
scatter(score(ts,1),score(ts,2),2,colors_p), hold on% pause(3)
end