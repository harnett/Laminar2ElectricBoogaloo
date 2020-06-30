function [x,sig] = PermStat1d(data,trgts,fill,nPerms,pv1,pv2)
% permutation cluster testing on 2d matrix with
% indices. test if subset of said 2d matrices are significantly different
% in blobs from 3d matrix
%data: subjxtime matrix to be shuffled
%trgts: (row) indices of group A
%fill: (row) indices of group B
%nPerms: number of shuffles
%pv1: p-value threshold for finding clusters of significant single voxels
%pv2: p-value threshold for statistical significance of a given cluster
%returns
%x: z-score significance (uncorrected)
%sig: 1s where significant cluster, 0s otherwise
%% stats for time-domain

numTrgts=length(trgts);
numFill=length(fill);
TrgtFill= [trgts(:)' fill(:)']; 
numTr=length(TrgtFill);

for k=1:nPerms
    TrgtFill=TrgtFill(randperm(length(TrgtFill)));
    TrgtPm=TrgtFill(1:numTrgts);
    FillPm=TrgtFill((numTrgts+1):end);
    trials=FillPm;
    
    filler=(nanmean(data(trials,:)));%filler=abs(nanmean(vec(:,:,trials),3));
    trials=TrgtPm;
    trgt=(nanmean(data(trials,:)));%trgt=abs(nanmean(vec(:,:,trials),3));
    if k==1
        pmdiff=trgt-filler;
    else
        pmdiff=cat(1,pmdiff,trgt-filler);
    end
%     pmdiff(:,:,k)=trgt-filler;
    disp(k)
end

t=(nanmean(data(trgts,:)));
f=(nanmean(data(fill,:)));

imu=(nanmean(pmdiff));
istd=(nanstd(pmdiff));

x=((t-f)-imu)./istd;

% imagesc(x)

tru=normcdf(-abs(x),0,1);
tru(tru>pv1)=0;

pmp=normcdf(-abs((pmdiff-repmat(imu,[size(pmdiff,1) 1]))./repmat(istd,[size(pmdiff,1) 1])),0,1);
pmp_th=pmp; clear pmp;
pmp_th(pmp_th>.05)=0;

ClstSz=[];
for k=1:size(pmp_th,1)
    tmp=pmp_th(k,:);
    s=bwconncomp(tmp);
    for kk=1:s.NumObjects
        ClstSz=cat(1,ClstSz,length(s.PixelIdxList{kk}));
    end
    disp(k)
end

c=sort(ClstSz);
clust_thresh=c(round((1-pv2)*length(c)));

b=bwconncomp(tru);
sig=zeros(size(tru));
for k=1:b.NumObjects
    if length(b.PixelIdxList{k})>=clust_thresh
        sig(b.PixelIdxList{k})=1;
    end
end
