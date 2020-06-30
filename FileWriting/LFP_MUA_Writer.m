function LFP_MUA_Writer(fdir,toilim,csc_to_phys)

cd(fdir)

lfp = LFP_Writer_Mapped(fdir,1000,[],toilim,csc_to_phys);

save('LFP_1k.mat','lfp','-v7.3')

clear lfp 

mua = MUA_Writer_Mapped(fdir,1000,[],toilim,csc_to_phys);

save('MUA_1k.mat','mua','-v7.3')

clear mua

end