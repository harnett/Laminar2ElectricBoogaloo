smask=zeros(size(lfp.trial{1},1),size(lfp.trial{1},2));
for k = 1 : 128
times = findspindlesv4(lfp.trial{1}(k,:),1000,8.5,16,gs); times = round(times.*1000);
td = times(:,2)-times(:,1); times(td<=.5,:) = [];
for kk = 1 : size(times,1)
smask(k,times(kk,1):times(kk,2)) = 1;
end
disp(k)
end

smask2=zeros(size(lfp.trial{1},1),size(lfp.trial{1},2));
for k = 1 : length(st_all)
    st = st_all{k}; std = st(:,2)-st(:,1); st(std<=500,:)=[];
    smask2(k,st2gs(st)) = 1;
end

sm=sum(smask);

smi = sm;

smi(sm>=12)=130; smi(smi~=130) = 0; smi(smi==130)=1;

c = contiguous(smi); c = c{2,2};

cd = c(:,2)-c(:,1);
c(cd<500,:) = [];

sm2=sum(smask2);

smi2 = sm2;

smi2(sm2>=12)=130; smi2(smi2~=130) = 0; smi2(smi2==130)=1;

c2 = contiguous(smi2); c2 = c2{2,2};

cd2 = c2(:,2)-c2(:,1);
c2(cd2<500,:) = [];

c = contiguous(smi.*smi2); c = c{2,2};

cd = c(:,2)-c(:,1);
c(cd<100,:) = [];

% 
d = c(2:end,1)-c(1:(end-1),2);
d = find(d<=500);
st_s = c(:,1); st_e = c(:,2);
st_s(d+1) = []; st_e(d) = [];
st = [st_s st_e];

cfg=[]; cfg.trl=zeros(size(st,1),3); cfg.trl(:,1) = st(:,1)-1000; cfg.trl(:,2) = st(:,2)+1000; lfp2=ft_redefinetrial(cfg,lfp);
lfp2.hdr=lfp.hdr;
cfg=[]; cfg.viewmode='vertical'; cfg.blocksize=5; cfg.channel = lfp.label([1:5:128]); ft_databrowser(cfg,lfp2)

