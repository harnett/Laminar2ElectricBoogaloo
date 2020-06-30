function Raw_30k_Writer(fdir,toilim,csc_to_phys)

TmpDat = LFP_Writer_Mapped(fdir,[],1:32,toilim,csc_to_phys);
d=int16(TmpDat.trial{1});

mkdir([fdir '\Kilo1-32'])

fId = fopen([fdir '\Kilo1-32\Raw30k_1-32.bin'],'w');
fwrite(fId,d,'int16');
fclose(fId);

clear

TmpDat = LFP_Writer_Mapped(fdir,[],33:64,toilim,csc_to_phys);
d=int16(TmpDat.trial{1});

mkdir([fdir '\Kilo33-64'])

fId = fopen([fdir '\Kilo33-64\Raw30k_33-64.bin'],'w');
fwrite(fId,d,'int16');
fclose(fId);

end