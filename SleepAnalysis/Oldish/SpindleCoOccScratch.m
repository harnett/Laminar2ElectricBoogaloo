smask=zeros(size(lfp.trial{1},1),size(lfp.trial{1},2));
for k = 1 : size(lfp.trial{1},1)
    [st,tr]=bycycle_spindle_detector([.5 .3 .3 .6],lfp,states,'C:\Users\Loomis\Documents\HO_FO_Spindles\PFC_A1_Lam\2019-06-23_18-23-06',k,0,1000);
    smask(k,st2gs(st)) = 1;
    disp(k)
end

sm=sum(smask);

smi = sm;

smi(sm>=12)=130; smi(smi~=130) = 0; smi(smi==130)=1;

c = contiguous(smi); c = c{2,2};

c(c<

sc = zeros(4,size(c,1)); nso = zeros(4,4);
for k = 1 : size(c,1)
    x=smask(:,c(k,1):c(k,2));
    pfcu = sum(x(1:32,:)); sc(1,k)=max(pfcu(:));
    pfcl = sum(x(33:64,:)); sc(2,k)=max(pfcl(:));
    a1u = sum(x(65:96,:)); sc(3,k)=max(a1u(:));
    a1l = sum(x(97:end,:)); sc(4,k)=max(a1l(:));
end
scc = sc; scc(sc>=2) = 1; scc = scc';
[c,ia,ic] = unique(scc','rows');

n = histcounts(ic);

nc = zeros(4,4);
for k = 1 : 4
    x = scc(find(scc(:,k)==1),:);
    for kk = 1 : 4
        y = x(find(x(:,kk)==1),:);
        nc(k,kk) = size(y,1)./size(x,1);
    end
end

nc = zeros(4,4);
for k = 1 : size(scc,1)
    if scc(k,1)
        x
    end
    if scc(k,2)
        x
    end
    if scc(k,1) && scc(k,2)
        x
    end
    if scc(k,1) && scc(k,2)
        x
    end
    if scc(k,1) && scc(k,2)
        x
    end
end
nc(1,1)


sc1 = sum(scc(:,1:2)'); sc1(sc1>=1) = 1; sc2 = sum(scc(:,3:4)'); sc2(sc2>=1) = 1;

scl = [sc1; sc2];

[cl,ial,icl] = unique(scl','rows');


lbl = {'a1 d','a1 u','a1 u+d','pfc d','pfc d + a1 u','pfc d + a1 u',...
    'pfc d + a1 u/d','pfc u','pfc u + a1 d','pfc u + a1 u','pfc u + a1 u/d','pfc u/d','pfc u/d + a1 d','pfc u/d + a1 u','pfc u/d and a1 u/d'};

hist(ic,50), set(gca,'XTick',1:15,'XTickLabel',lbl)

nc = []; sc = [];
for k = 1 : size(c,1)
    [nct,ci] = max(sm(c(k,1):c(k,2)));
    nc(k) = nct; t = smask(:,(ci+c(k,1)-1)); sc(k) = mean(find(t));
end

ns=[]; sl=[];
for k = 1 : size(smask,1)
    x = smask(k,:);
    c = contiguous(x); c = c{2,2};
    ns(k) = size(c,1); sl(k) = mean(c(:,2)-c(:,1));
end