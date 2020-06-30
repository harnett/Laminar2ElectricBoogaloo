clear

addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\djh'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))

cd Y:\Milan\DriveDataSleep

load('subs')

thctxa1=[]; ctxtha1=[]; thctxa2=[]; ctxtha2=[];subsi=[]; dphsa_ind=1; subsi=[];
for k = [1 3:6]
    thctx1=[]; ctxth1=[]; thctx2=[]; ctxth2=[];
    cd(subs{k})
    if k==3 || k==4
        load('spinddelt_glm_sub.mat','thctx1','ctxth1','thctx2','ctxth2')
    else
    load('spinddelt_glm_subfin.mat','thctx1','ctxth1','thctx2','ctxth2')
    end
    subsi = [subsi ones(1,size(thctx1,1)).*k];
    thctxa1 = [thctxa1; thctx1]; ctxtha1 = [ctxtha1; ctxth1]; 
    thctxa2 = [thctxa2; thctx2]; ctxtha2 = [ctxtha2; ctxth2]; 
    cd(subs{k})
end
cd Y:\Milan\DriveDataSleep
save('spinddelt_cpling_glm_all_fin2.mat','thctxa1','ctxtha1','thctxa2','ctxtha2','subsi')

% save