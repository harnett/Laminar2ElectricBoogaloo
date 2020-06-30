function [x,sig] = PermStat(data,trgts,fill,nPerms)
% permutation cluster testing on 'cube' (multiple 2d matrices) with
% indices. test if subset of said 2d matrices are significantly different
% in blobs from 3d matrix
%% stats for time-domain

numTrgts=length(trgts);
numFill=length(fill);
TrgtFill= [trgts(:); fill(:)]; 
numTr=length(TrgtFill);

for k=1:nPerms
    TrgtFill=TrgtFill(randperm(length(TrgtFill)));
    TrgtPm=TrgtFill(1:numTrgts);
    FillPm=TrgtFill((numTrgts+1):end);
    trials=FillPm;
    filler=(nanmean(data(:,:,trials),3));%filler=abs(nanmean(vec(:,:,trials),3));
    trials=TrgtPm;
    trgt=(nanmean(data(:,:,trials),3));%trgt=abs(nanmean(vec(:,:,trials),3));
    if k==1
        pmdiff=trgt-filler;
    else
        pmdiff=cat(3,pmdiff,trgt-filler);
    end
%     pmdiff(:,:,k)=trgt-filler;
    disp(k)
end

t=(nanmean(data(:,:,trgts),3));
f=(nanmean(data(:,:,fill),3));

imu=(nanmean(pmdiff,3));
istd=(nanstd(pmdiff,[],3));

x=((t-f)-imu)./istd;

% imagesc(x)

tru=normcdf(-abs(x),0,1);
tru(tru>.01)=0;

pmp=normcdf(-abs((pmdiff-repmat(imu,[1 1 size(pmdiff,3)]))./repmat(istd,[1 1 size(pmdiff,3)])),0,1);
pmp_th=pmp; clear pmp;
pmp_th(pmp_th>.01)=0;

ClstSz=[];
for k=1:size(pmp_th,3)
    tmp=pmp_th(:,:,k);
    s=bwconncomp(tmp);
    for kk=1:s.NumObjects
        ClstSz=cat(1,ClstSz,length(s.PixelIdxList{kk}));
    end
    disp(k)
end

c=sort(ClstSz);
clust_thresh=c(round(.99*length(c)));

b=bwconncomp(tru);
sig=zeros(size(tru));
for k=1:b.NumObjects
    if length(b.PixelIdxList{k})>=clust_thresh
        sig(b.PixelIdxList{k})=1;
    end
end
