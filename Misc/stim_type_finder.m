function [stim_types] = stim_classifier(ind)
brk=ind(1);
tpe=0;
stim_types=[];
for i=2:length(ind)
    tpe=tpe+1;
    if (ind(i)-ind(i-1))>=1000
       brk = [brk ind(i)];
       stim_types=[stim_types tpe];
       tpe=0;
    end
end
stim_types=[stim_types tpe+1];
stim_types=stim_types./2;