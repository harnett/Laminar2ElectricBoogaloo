function [x] = PermStatNoClust(data,trgts,fill,nPerms)
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

