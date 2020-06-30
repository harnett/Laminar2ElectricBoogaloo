function spkr = spk_rtest_statewrap(lfp,unitdata,fqs,states,fs)
 
st_label = {'NREM','REM','Wake'};

 parfor s = 1 : length(states)
     disp(['doing r-tests for ' st_label{s}]) 
 gs=time_STATE2gs(states(s).t);
 
 [rs,zs,pvs,angs] = spk_rtest(lfp,unitdata,fqs,gs,fs);
 
 spkr(s).rs = rs; spkr(s).zs = zs; spkr(s).pvs = pvs; spkr(s).angs = angs;
 end
 
end