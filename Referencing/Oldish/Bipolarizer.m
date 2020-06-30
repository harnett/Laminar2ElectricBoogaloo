data.trial{1}(9:10,:) = data.trial{1}(22:23,:); % IMPORTANT
chgrps=[11 22];%[1 10];%
bi=[];
lbl={}; lbl_ind=1;
for grp=1:size(chgrps,1)
    bitmp=[];
    chs=chgrps(grp,1):chgrps(grp,2);
    for ch1=chs
        for ch2=(ch1+1):max(chs)
            bitmp=[bitmp; data.trial{1}(ch1,:)-data.trial{1}(ch2,:)];
            lbl{lbl_ind}=strcat(num2str(ch1),num2str(ch2));
            lbl_ind=lbl_ind+1;
        end
    end
    bi=[bi; bitmp];
end

data.trial{1}=bi;
data.label=lbl;

%data.trial{1}=[bi; data.trial{1}(11:22,:)]; 
%data.label=[lbl, data.label(11:22)'];
clear bi bitmp ch1 ch2 lbl chs chgrps grp lbl_ind

cfg=[]; cfg.channel = {'78','58','610','12','37','35','14','47'}; data=ft_preprocessing(cfg,data);

'1219','1719' %(for now...)