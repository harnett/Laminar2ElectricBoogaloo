function LFP_MUA_Raw30k_Writer_DualLam_TMP(fdir,toilim,csc_to_phys)

cd(fdir)
% 
% lfp = LFP_Writer_Mapped_v2(fdir,1000,[],toilim,1000,csc_to_phys);
% 
% save('LFP_1k.mat','lfp','-v7.3')
% 
% clear lfp 
% 
% mua = MUA_Writer_Mapped(fdir,1000,[],toilim,csc_to_phys);
% 
% save('MUA_1k.mat','mua','-v7.3')
% 
% clear mua

TmpDat = LFP_Writer_Mapped_v2(fdir,[],65:96,toilim,30000,csc_to_phys);
d=int16(TmpDat.trial{1});

mkdir([fdir '\Kilo65-96'])

fId = fopen([fdir '\Kilo65-96\Raw30k_65-96.bin'],'w');
fwrite(fId,d,'int16');
fclose(fId);

clear d TmpDat fID

TmpDat = LFP_Writer_Mapped_v2(fdir,[],97:128,toilim,30000,csc_to_phys);
d=int16(TmpDat.trial{1});

mkdir([fdir '\Kilo97-128'])

fId = fopen([fdir '\Kilo97-128\Raw30k_97-128.bin'],'w');
fwrite(fId,d,'int16');
fclose(fId);

clear d TmpDat fID

end