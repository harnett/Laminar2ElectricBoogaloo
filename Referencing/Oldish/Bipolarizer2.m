function bilfp = lfp_bipolarizer(lfp,chgrps)
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
end
data.fsample = lfp.fsample;
data.trial{1}=bi;
data.label=lbl;
data.time{1}=lfp.time{1};