function sta = LaminarSTA_StateWrapper_NoReReference(unitdata,lfp,winlen,fs,unit_selected,states,sdir)
%winlen is samples before and after

%rows of output are states, columns are different references

% compute 

sta = cell(1,3);

parfor s = 1 : 3
    gs = time_STATE2gs(states(s).t);
    sta{s} = LaminarSTAv2(unitdata,lfp,winlen,fs,unit_selected,gs);
    disp(s)
end

if ~isempty(sdir)
if ~exist([sdir '/analysis_out'], 'dir')
    mkdir([sdir '/analysis_out'])
else
    cd([sdir '/analysis_out'])
end
save('sta.mat','sta','-v7.3')
end
