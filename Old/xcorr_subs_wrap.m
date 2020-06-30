% loop thru all sessions / states compute XCorrs!
clear

cd Y:\Milan\DriveDataSleep

load('subs')
bfile=[]; bfile_ind = 1; statename = {'nrem','rem','wake'};
for k = 1 : length(subs)
    cd(subs{k})
    load('good_sess.mat')
    for kk = 1 : length(good_sess)
        cd(good_sess{kk}) 
        %if ~isfile('xcorr_out_nrem.mat')
        
        load('States.mat')
        
        load('unitdata.mat')
        
        for s = 1 : 3
        if ~isfile(['xcorr_out_' statename{s} '.mat'])
        gs = time_STATE2gs(states(s).t);
        [cch_rl,cch_pred,cch_prob,sigflag] = xcorrTimestampsCumPoiss(unitdata,[],[],gs);
        save(['xcorr_out_' statename{s} '.mat'],'cch_rl','cch_pred','cch_prob','sigflag','-v7.3')
        end
        end
        
%         [cch_rl,cch_pred,cch_prob,sigflag] = xcorrTimestampsCumPoiss(unitdata,[],[],[]);
%         save('xcorr_out_allstate.mat','cch_rl','cch_pred','cch_prob','sigflag','-v7.3')
        
        disp(kk)
    end
    disp(k)
end