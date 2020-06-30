function [bilfp,bictxch,bithch] = lfp_bipolarizer(lfp,chgrps)
lfp.fsample = 1000;
%chgrps inputted such as: {[2:10],[1 11:18]}
%MAKE SURE TO PUT CORTEX FIRST
bi = []; lbl_ind=1;
for c = 1 : 2
chs=chgrps{c}; 
for k = 1 : (length(chs)-1)
    for kk = (k+1) : length(chs)
        ch1=chs(k); ch2=chs(kk);
        bi=[bi; lfp.trial{1}(ch1,:)-lfp.trial{1}(ch2,:)];
        lbl{lbl_ind}=strcat(num2str(ch1),num2str(ch2));
        lbl_ind=lbl_ind+1;
    end
end
if c==1
bictxch = 1:(lbl_ind-1);
end
end
bithch = (bictxch(end)+1):lbl_ind-1;
bilfp.fsample = lfp.fsample;
bilfp.trial{1}=bi;
bilfp.label=lbl;
bilfp.time{1}=lfp.time{1}; 