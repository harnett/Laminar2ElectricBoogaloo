cd Y:\Milan\DriveDataSleep
clear
load('subs.mat')

subsi=[]; pvsaa=[]; zsaa=[]; rsaa=[];
for k = [1 3:6]
    cd(subs{k})
    load('spkr_sumbi.mat')
    pvsaa = cat(3,pvsaa,pvsa);
    zsaa = cat(3,zsaa,zsa);
    rsaa = cat(3,rsaa,rsa);
    subsi = [subsi ones(1,length(zsa)).*k];
end
cd Y:\Milan\DriveDataSleep
save('spkr_allbi.mat','pvsaa','zsaa','rsaa','subsi')
%%
clear
cd Y:\Milan\DriveDataSleep
load('area_all_units.mat')
load('spkr_allbi.mat')
res = nan(2,2,4);
uarea = uarea(subsi>=3);
pvsaa = pvsaa(:,:,subsi>=3);
for rc = 1 :2
    for o = 1 : 2
sg = zeros(1,length(pvsaa)); sg(squeeze(pvsaa(rc,o,:))<=.01)=1;
for k = 1 : 4
res(rc,o,k) = mean(sg(uarea==k));
end
    end
end