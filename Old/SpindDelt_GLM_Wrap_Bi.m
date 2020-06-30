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

thctxa1=[]; ctxtha1=[]; thctxa2=[]; ctxtha2=[];subsi=[]; dphsa_ind=1;
for k = [1 5]
    cd(subs{k})
    load('good_sess.mat')
    thctx1=[]; ctxth1=[]; thctx2=[]; ctxth2=[];
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        load('unitdata.mat')
        load('States.mat')
        % detect spindles
%         if ~exist('spinddelt_cpling_glm_sess.mat')
        load('LFPBi_StCh.mat')
        times_all = findspindlesv5(data,1000,9,17,time_STATE2gs(states(1).t),2.8);
        st = times_all(find(times_all(:,3)==1),1:2);
        if isempty(st)
            continue
        end
        
        %load('spind_delt_couplingBi.mat')
        [dphs,pv,z] = spind_delta_phscoupling(data,times_all(times_all(:,3)==1,1:2));
        % which spindles are closest to circ_mean value?
        [~,cds] = sort(abs(circ_dist(dphs,circ_mean(dphs'))));
        % run glm on these spindle classes separately
        [wxa1,wva1] = GLMSpindlePark(data,unitdata,st,1,cds(1:round(length(cds)./4)));
        [wxa2,wva2] = GLMSpindlePark(data,unitdata,st,1,cds((round(length(cds).*.75)+1):end));
%         else
%             load('spinddelt_cpling_glm_sess.mat')
%         end
        %determine thalamic / cortical channels
        a = cell(1,length(unitdata));
        for ui = 1 : length(unitdata)
            a{ui} = unitdata(ui).area;
        end
        ThCh = union(find(strcmp(a,'MD')),find(strcmp(a,'MGB')));
        CtxCh = union(find(strcmp(a,'PFC')),find(strcmp(a,'A1')));
        %look at thalamocortical / corticothalamic coupled/noncouples
        %spindles
        thctxsess1 = wxa1(CtxCh,:,ThCh);
        ctxthsess1 = wxa1(ThCh,:,CtxCh);
        thctxsess1 = reshape(permute(thctxsess1,[1 3 2]),[size(thctxsess1,1)*size(thctxsess1,3) size(thctxsess1,2)]);
        ctxthsess1 = reshape(permute(ctxthsess1,[1 3 2]),[size(ctxthsess1,1)*size(ctxthsess1,3) size(ctxthsess1,2)]); 
        
        thctxsess2 = wxa2(CtxCh,:,ThCh);
        ctxthsess2 = wxa2(ThCh,:,CtxCh);
        thctxsess2 = reshape(permute(thctxsess2,[1 3 2]),[size(thctxsess2,1)*size(thctxsess2,3) size(thctxsess2,2)]);
        ctxthsess2 = reshape(permute(ctxthsess2,[1 3 2]),[size(ctxthsess2,1)*size(ctxthsess2,3) size(ctxthsess2,2)]);
        
        save('spinddelt_cpling_glm_sessfin.mat','thctxsess1','ctxthsess1','wva1','wxa1','thctxsess2','ctxthsess2','wva2','wxa2')
        thctx1 = [thctx1; thctxsess1]; ctxth1 = [ctxth1; ctxthsess1];
        thctx2 = [thctx2; thctxsess2]; ctxth2 = [ctxth2; ctxthsess2];
    end
    thctxa1 = [thctxa1; thctx1]; ctxtha1 = [ctxtha1; ctxth1]; 
    thctxa2 = [thctxa2; thctx2]; ctxtha2 = [ctxtha2; ctxth2]; 
    subsi = [subsi ones(1,size(thctx1,1)).*k];
    cd(subs{k})
    save('spinddelt_glm_subfin.mat','thctx1','ctxth1','thctx2','ctxth2')
end
cd Y:\Milan\DriveDataSleep
save('spinddelt_cpling_glm_all_fin.mat','thctxa1','ctxtha1','thctxa2','ctxtha2','subsi')

% save