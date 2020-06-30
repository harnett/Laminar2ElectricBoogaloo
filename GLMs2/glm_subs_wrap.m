% loop thru all sessions / states compute GLMs!
clear

cd Y:\Milan\DriveDataSleep

load('subs')

for k = 1 : length(subs)
    cd(subs{k})
    load('good_sess.mat')
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        if ~isfile('glm_out_nrem.mat')
        load('States.mat')
        load('unitdata.mat')
        gs = time_STATE2gs(states(1).t);
        if length(gs)>=(60*20*1000)
            gs = gs(1:(60*20*1000));
        end
        [sps,pGLMconst2,pGLMhistfilts2,ratepred2,pGLMconst1,pGLMhistfilt1,ratepred1,spm,gu] = glmCoupled(unitdata,[],[],gs,10,.001,80);
        save('glm_out_nrem.mat','sps','pGLMconst2','pGLMhistfilts2','ratepred2','pGLMconst1','pGLMhistfilt1','ratepred1','spm','gu','-v7.3')
        end
        disp(kk)
    end
    disp(k)
end
