function Raw30k_Writer_Mapped(fdir,ds,chs,toilim,csc_to_phys)

%converts .CSCs into a fieldtrip format data structure with LFPs

%fdir: directory with CSCs
%chs: chs you want to read(leave blank if all)
%toilim: upper and lower time bounds (in seconds) of data you want to read
%(blank if all data)
%csc_to_phys: how to map each CSC to physical space. 

currentfolder = pwd;

addpath(genpath('C:\Users\Loomis\Documents\Packages\MatlabImportExport_v6.0.0'))
addpath(genpath('C:\Users\Loomis\Documents\Packages\Stream Channel'))

%addpath(genpath('C:\Users\Loomis\Documents\Packages\NPMK-4.5.3.0\NPMK'))
cd(fdir)

dncs = dir('*.ncs'); ncsf = {dncs.name};

%resort ncsf so it's in correct channel order

num = [];

for tetr = 1 : length(ncsf)
    [~,tetrf,~] = fileparts(ncsf{tetr});
    num = [num str2double( tetrf( regexp( tetrf,'\d') ) )];
end

[~,srt] = sort(num); ncsf = ncsf(srt); clear num

ncsf = ncsf(csc_to_phys);

%select which channels we're loading
if isempty(chs)
    chs = 1 : length(ncsf);
end

%[Timestamps] = Nlx2MatCSC('CSC1.ncs',[1 0 0 0 0],...
%0, 1,1);

dch = 1;



for tetr = chs
%    if ~isempty(toilim)
%             [Samples] = Nlx2MatCSC( ncsf{tetr},[0 0 0 0 1],...
%                       0, 4,[round(toilim(1).*30000./512) round(toilim(2).*30000./512)]+Timestamps(1));
        [Samples] = Nlx2MatCSC( ncsf{tetr},[0 0 0 0 1],...
            0, 1,1);

    Samples = Samples(:);
    
    if ~isempty(toilim)
    Samples = Samples(round(toilim(1).*30000):round(toilim(2).*30000));
    end
    
    if ~isempty(ds) % check if we're downsampling...
        Samples = Samples(1:ds:end);
    end
    
    if tetr == chs(1)
        d = nan(length(chs),length(Samples));
    end
    
    d(dch,:) = Samples'; dch = dch+1;
    
    disp(tetr)
end

d=int16(d);

mkdir([fdir '\KiloDat'])

fId = fopen([fdir '\KiloDat\Raw30k.bin'],'w');
fwrite(fId,d,'int16');
fclose(fId);

cd(currentfolder)

end