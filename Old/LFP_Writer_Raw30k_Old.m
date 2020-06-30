function LFP_Writer_Raw30k_Old(csc_to_phys,samplim)

%creates 2 .bin files of chs 1-32 and 33-64; can then feed into kilosort

%use in directory of interest
addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))

dncs = dir('*.ncs'); ncsf = {dncs.name};

%resort ncsf so it's in correct channel order

num = [];

for tetr = 1 : length(ncsf)
    [~,tetrf,~] = fileparts(ncsf{tetr});
    num = [num str2double( tetrf( regexp( tetrf,'\d') ) )];
end

[~,srt] = sort(num); ncsf = ncsf(srt); clear num

%now resort in order derived from channel map

ncsf = ncsf(csc_to_phys);

dat=[];
for k = 1:32
[Samples] = Nlx2MatCSC(ncsf{k},[0 0 0 0 1], 0, 1, [] );
Samples = Samples(:)';
if ~isempty(samplim)
    Samples = Samples(samplim(1):samplim(2));
end
dat = [dat; Samples];
end

dat=int16(dat);

fId = fopen('Raw30k_Chs1-32.bin','w');
fwrite(fId,dat,'int16');
fclose(fId);

dat=[];
for k = 33:64
[Samples] = Nlx2MatCSC(ncsf{k},[0 0 0 0 1], 0, 1, [] );
Samples = Samples(:)';
if ~isempty(samplim)
    Samples = Samples(samplim(1):samplim(2));
end
dat = [dat; Samples];
end

dat=int16(dat);

fId = fopen('Raw30k_Chs33-64.bin','w');
fwrite(fId,dat,'int16');
fclose(fId);

clear
end