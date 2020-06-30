function Fieldtrip2KiloBin(data,fn)
d=int16(data.trial{1});
fId = fopen(fn,'w');
fwrite(fId,d,'int16');
fclose(fId);