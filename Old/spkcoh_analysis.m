cd Y:\Milan\DriveDataSleep
load('subs')
for k = 1 : length(subs)
cd(subs{k})
load('good_sess.mat')
sa=[]; psa=[]; f=[];
for kk = 1 : length(good_sess)
cd(good_sess{kk})
if isfile('spkcoh.mat')
load('unitdata.mat')
load('spkcoh.mat')
a = cell(1,length(unitdata));
for kkk =1 : length(unitdata)
a{kkk} = unitdata(kkk).area;
end
[~,~,a]=unique(a);
s = spkcoh(1).C; f = spkcoh(1).f;
s = s(find(a==1),find(a==2),:);
s = reshape(s,[size(s,1).*size(s,2) size(s,3)]);

ps = spkcoh(1).phi;
ps = ps(find(a==1),find(a==2),:);
ps = reshape(ps,[size(ps,1).*size(ps,2) size(ps,3)]);

sa = [sa; s];
psa = [psa; ps];
end
end
cd(subs{k})
save('spkcohsub.mat','sa','f','psa')
disp(k)
end
