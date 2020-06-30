function frqshff = frqshff_parfor_fun(frq)

frqshff=frq;
frqsz = size(frq.fourierspctrm,2);

for kk=1:frqsz
        tmp=squeeze(frqshff.fourierspctrm(:,kk,:));
        tmp=tmp(randperm(size(tmp,1)),:);
        frqshff.fourierspctrm(:,kk,:)=tmp;
end