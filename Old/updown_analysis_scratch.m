load('downup_all.mat')
load('chs_across_sessions.mat')

d=[];
for k = 1 : 4
    cfg=[]; a = ft_timelockanalysis(cfg,downup_all{k});
    a = a.avg(65:end,:);
    a=a(:,[1:125 127:end]);
    for kk = 1 : size(a,1)
        a(kk,:) = smooth(a(kk,:),20);
    end
    subplot(2,2,k)
    a = zscore(a,[],2);
    a=a(:,10:(end-10));
    imagesc(a)
    d = [d; a];
end

x=1:239';

[~,s] = sort(chs);
d=d(s,:);

%d2=abs(d - repmat(.5*max(d,[],2),[1 size(d,2)]));

[~,m] = max(d,[],2);

mg = intersect(find(m>=100),find(m<=140));

figure
imagesc(d), hold on
scatter(m(mg),x(mg),15,'k')


[r,pv]=corr(x(mg)',m(mg))

figure 
scatter(x(mg),m(mg),100,'k','filled'), lsline

%%

load('updown_all.mat')
load('chs_across_sessions.mat')

d=[];
for k = 1 : 4
    cfg=[]; a = ft_timelockanalysis(cfg,updown_all{k});
    a = a.avg(65:end,:);
    a=a(:,[1:75 77:end]);
    for kk = 1 : size(a,1)
        a(kk,:) = smooth(a(kk,:),20);
    end
    subplot(2,2,k)
    a = zscore(a,[],2);
    a=a(:,10:(end-10));
    %imagesc(a)
    d = [d; a];
end

x=1:239';

[~,s] = sort(chs);
d=d(s,:);

%d2=abs(d - repmat(.5*max(d,[],2),[1 size(d,2)]));

[~,m] = min(d,[],2);

figure
imagesc(d), hold on
scatter(m(m>=99),x(m>=99),100,'k','filled')

[r,pv]=corr(x(m>=99)',m(m>=99))

figure 
scatter(x(m>=99),m(m>=99),100,'k','filled'), lsline
%%
d2=abs(d - repmat(.5*min(d,[],2),[1 size(d,2)]));

[~,m] = min(d2,[],2);

figure
imagesc(d), hold on
scatter(m(m>=50),x(m>=50),100,'k','filled')

[r,pv]=corr(x(m>=50)',m(m>=50))

figure 
scatter(x(m>=50),m(m>=50),100,'k','filled'), lsline