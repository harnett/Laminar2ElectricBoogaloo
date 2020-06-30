function [dat_out] = fieldtrip2mat_epochs(dat_in)
for i=1:length(dat_in.trial)
    if i==1
        dat_out=dat_in.trial{i};
    else
        dat_out=cat(3,dat_out,dat_in.trial{i});
    end
end