function sta = LaminarSTA_StateWrapper(unitdata,lfp,winlen,fs,unit_selected,states,sdir)
%winlen is samples before and after

%rows of output are states, columns are different references

% compute 

nCh = 32;

for r = 1 : 3
    if r == 1
        lfp2 = lfp;
    elseif r ==2
    lfp2=LFP_ChanDownsamp_Mean(lfp,nCh);
    for k = 1 : length(lfp2.trial)
    lfp2.trial{k}(1:(end-1),:) = diff(lfp2.trial{k});
    end
    cfg=[]; cfg.channel=lfp2.label(1:(end-1)); lfp2=ft_preprocessing(cfg,lfp2); lfpbi = lfp2;
    elseif r ==3
    lfp2 = lfpbi;
    for k = 1 : length(lfp2.trial)
        lfp2.trial{k}(2:(end-1),:)=pg2csd_h3lam(lfpbi.trial{k});
    end
    cfg=[]; cfg.channel=lfp2.label(2:(end-1)); lfp2=ft_preprocessing(cfg,lfp2);
    end
for s = 1 : 3
    gs = time_STATE2gs(states(s).t);
    sta{s,r} = LaminarSTAv2(unitdata,lfp2,winlen,fs,unit_selected,gs);
    disp(s)
end
end

if ~isempty(sdir)
if ~exist([sdir '/analysis_out'], 'dir')
    mkdir([sdir '/analysis_out'])
else
    cd([sdir '/analysis_out'])
end
save('sta.mat','sta','-v7.3')
end
