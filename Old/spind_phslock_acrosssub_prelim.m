clear

cd Y:\Milan\DriveDataSleep

load('subs')

sn = {'WT19','M4-3','WT14','WT31','S3'}; 

z=[]; a={}; s=[]; p=[]; zs=[]; ang=[]; angdelt=[];
for k = [1:5]
    cd(subs{k})
    load('spkr_allslp.mat')
    load('area.mat')
    load('good_ctx_th_ch.mat')
    load('gch.mat')
    ch = 1;
    z = [z; squeeze(zsa(ch,2,:))]; a = [a aa]; s = [s repmat(sn(k),[1 length(aa)])];
    ang = [ang; squeeze(angsa(ch,2,:))];
    angdelt = [angdelt; squeeze(angsa(ch,1,:))];
    zs = [zs; squeeze(zsa(ch,1,:))];
    p = [p; squeeze(pvsa(ch,1,:))];
end

sig_spind = find(p<=.001);

length(intersect(sig_spind,find(strcmp(a,'MD'))))./length(find(strcmp(a,'MD')))
length(intersect(sig_spind,find(strcmp(a,'MGB'))))./length(find(strcmp(a,'MGB')))
length(intersect(sig_spind,find(strcmp(a,'PFC'))))./length(find(strcmp(a,'PFC')))
length(intersect(sig_spind,find(strcmp(a,'A1'))))./length(find(strcmp(a,'A1')))

ang = ang(sig_spind); a = a(sig_spind);

angdelt = angdelt(sig_spind); a = a(sig_spind);

mean(ps(find(strcmp(a,'PFC'))))

g = gramm('x',a,'y',(z))
g.violin()
g.draw()

for chi = [1 : 6]
z=[]; a={}; s=[];
for k = [1:5]
    cd(subs{k})
    load('spkr_sum.mat')
    load('area.mat')
    z = [z; squeeze(zsa(chi,2,:))]; a = [a aa]; s = [s repmat(sn(k),[1 length(aa)])];
end

g = gramm('x',a,'y',(z))
g.stat_boxplot()
g.draw()

au = {'MD','PFC','MGB','A1'};

for k = 1 : 4
    for kk = 1 : 4
    at(k,kk) = ranksum(z(find(strcmp(a,au{k}))),z(find(strcmp(a,au{kk}))));
    end
end
subplot(1,6,chi)
imagesc(at)
end