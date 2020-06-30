addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))
addpath(genpath('C:\Users\Loomis\Documents\Scripts'))
addpath('C:\Users\Loomis\Documents\Packages\fieldtrip-20190418')
ft_defaults
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\djh'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
%%
clear

cd Y:\Milan\DriveDataSleep

load('subs')

thctxa=[]; ctxtha=[]; subsi=[];
for k = 1 : length(subs)
    cd(subs{k})
    load('good_sess.mat')
    load('good_ctx_th_ch.mat')
    load('gch.mat')
    thctx=[]; ctxth=[];
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        load('LFP_1k.mat')
        load('States.mat')
        load('unitdata.mat')
        times_all = findspindlesv5(data,1000,9,17,time_STATE2gs(states(1).t),2.4);
        st = times_all(find(times_all(:,3)==1),1:2);
        if isempty(st)
            continue
        end
        
        [wxa,wva] = GLMSpindlePark(data,unitdata,st,good_ctx_th_ch);
        wxa(abs(wxa)>=5)=nan;
        
        a = cell(1,length(unitdata));
        for ui = 1 : length(unitdata)
            a{ui} = unitdata(ui).area;
        end
        ThCh = union(find(strcmp(a,'MD')),find(strcmp(a,'MGB')));
        CtxCh = union(find(strcmp(a,'PFC')),find(strcmp(a,'A1')));
        thctxsess = wxa(CtxCh,:,ThCh);
        ctxthsess = wxa(ThCh,:,CtxCh);
        thctxsess = reshape(permute(thctxsess,[1 3 2]),[size(thctxsess,1)*size(thctxsess,3) size(thctxsess,2)]);
        ctxthsess = reshape(permute(ctxthsess,[1 3 2]),[size(ctxthsess,1)*size(ctxthsess,3) size(ctxthsess,2)]); 
        save('spind_glm_sess.mat','thctxsess','ctxthsess','wva','wxa')
        thctx = [thctx; thctxsess]; ctxth = [ctxth; ctxthsess];
%         thctxv = wva(CtxCh,:,ThCh);
%         ctxthv = wva(ThCh,:,CtxCh);
    end
    cd(subs{k})
    save('spind_glm_sub.mat','thctx','ctxth')
    thctxa = [thctxa; thctx]; ctxtha = [ctxtha; ctxth]; 
    subsi = [subsi ones(1,size(thctx,1)).*k];
    disp(k)
%     save('spkr_sum.mat','rsa','zsa','pvsa','angsa','sessia')
end
cd Y:\Milan\DriveDataSleep
save('spind_glm_all.mat','thctxa','ctxtha','subsi')