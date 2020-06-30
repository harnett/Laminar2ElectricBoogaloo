function BatchWriteFd(directory, varargin)
addpath(genpath('C:\Users\Loomis\Documents\Packages\Clustering and Basic Analysis'))
narginchk(1,2)
if nargin == 1
    filelist = dir(fullfile(directory,'*.ntt'));
elseif nargin == 2 && varargin{1} == 1
    [filename, pathname] = uigetfile('*.ntt','MultiSelect','on');
    if ischar(filename)
        filelist(1).name = filename;
        filelist(1).folder = pathname;
    else
        for n=1:numel(filename)
            filelist(n).name = filename{n};
            filelist(n).folder = pathname;
        end
    end
        
end

global MClust_NeuralLoadingFunction
MClust_NeuralLoadingFunction = 'myLoadingEngine';

ChannelValidity = [1 1 1 1];
record_block_size = 20000; % maximum number of spikes to load into memory at one time
template_matching = 0; % used to remove noise spikes which are not "spike-like,", template-matching is not a currently supported function
NormalizeFDYN = 'no'; % 'yes' if you want to normalize the feature data files to mean = 0, std = 1
FeaturesToUse = {'energy','peak','time','valley'};
FD_directory = directory;

for n=1:length(filelist)
    ntt_file = fullfile(filelist(n).folder,filelist(n).name);
    Write_fd_file(FD_directory,ntt_file,FeaturesToUse,ChannelValidity, record_block_size, template_matching, NormalizeFDYN);
end