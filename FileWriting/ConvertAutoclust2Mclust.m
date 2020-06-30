function ConvertAutoclust2Mclust()
% ConvertAutoclust2Mclust(autoclust_filename) takes the filename of an
% autoclust mat file and then creates a .clusters file for use with MClust.
% Assumes that all channels are valid. 
% ConvertAutoclust2Mclust(autoclust_filename, dest_fn, channel_validity) used when
% not all channels are valid. ex: [1 1 0 1]

% narginchk(1,3)


% if exist(auto_fn,'file') ~= 2
%     auto_fn = fullfile(pwd,auto_fn);
% end
% 
% if exist(auto_fn,'file') ~= 2
%     error('File does not exist: %s', auto_fn)
% end

[filename, pathname] = uigetfile('MultiSelect','on');
if ischar(filename)
    filelist(1).name = filename;
    filelist(1).folder = pathname;
else
    for n=1:numel(filename)
        filelist(n).name = filename{n};
        filelist(n).folder = pathname;
    end
end

for n=1:length(filelist)
    auto_fn = fullfile(filelist(n).folder,filelist(n).name);
    % Load seed cluster file & mat file from autoclust
    seed = load('seed.clusters','-mat');
    auto = load(auto_fn);
    tt = fields(auto);
    auto = auto.(tt{1});

    channel_validity = [1 1 1 1];
    [folder,~,~] = fileparts(auto_fn);
    dest_fn = sprintf('%s_converted.clusters',auto_fn(1:end-4));

    num_clusters = numel(auto.labels);
    num_spikes = size(auto.waveforms,3);

    % get the random variables out of the way
    seed.MClust_ChannelValidity = channel_validity;
    [seed.MClust_ClusterFileNames{1:num_clusters}] = deal('functions');
    seed.featureindex = 1:num_spikes;

    % iterate through clusters and put them in mcconvexhulls
    seed.MClust_Clusters= cell(1,num_clusters);
    for n=1:num_clusters
       cluster_spikes = auto.labels{n};
       MCC=mcconvexhull();
       MCC.myPoints = cluster_spikes;
       MCC.myOrigPoints = cluster_spikes; % not sure why this is necessary and/or if this is necessary but yolo
       seed.MClust_Clusters{n} = MCC;
    end

    [folder,~,~] = fileparts(auto_fn);
    save(dest_fn,'-struct','seed')
end