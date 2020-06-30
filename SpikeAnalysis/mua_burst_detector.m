
function all_edge = mua_burst_detector(mua,fqs,cent_crit, cent_time, edge_crit, edge_time, time_inds, chs)

% derive MUA
u = mua.trial{1}; 

if isempty(time_inds)
    time_inds = 1:size(u,1);
end
if isempty(chs)
    chs = 1:size(u,1);
end

u = mean(u(chs,:));

% smooth with X ms box kernel

u = smooth(u,40);

% filter MUA in band

u = dat2fieldtrip(u',1000);

cfg=[]; cfg.bpfilter='yes'; cfg.bpinstabilityfix='reduce'; cfg.bpfreq=fqs; u = ft_preprocessing(cfg,u); 

cfg=[]; cfg.hilbert='abs'; u = ft_preprocessing(cfg,u);

% find when exceeds 1.5 for >300 ms

u = fieldtrip2mat_epochs(u);

u = filloutliers(u,'previous'); % REPLACES OUTLIERS

u = ( u - mean( u(time_inds) ) ) ./ std( u(time_inds) ); % compute std and mean of desired state;

u_edge = ( u >= edge_crit );

u_edge_epochs = contiguous(u_edge, 1);

u_edge_epochs = u_edge_epochs{2};

u_edge_epochs((u_edge_epochs(:,2)-u_edge_epochs(:,1)) < edge_time, :) = [];

% for each of these, see if exceeds 2.5 std for >100ms

all_edge = [];

for k = 1 : size(u_edge_epochs,1)
    
    u_epoch_inds = u_edge_epochs(k,1):u_edge_epochs(k,2);
    
    u_epoch = u(u_epoch_inds);
    
    u_cent = (u_epoch >= cent_crit);
    
    if max(u_cent) == 0
        continue
    end
    
    u_cent_epochs = contiguous(u_cent,1);
    
    u_cent_epochs = u_cent_epochs{2};
    
    u_cent_epochs((u_cent_epochs(:,2)-u_cent_epochs(:,1)) < cent_time, :) = [];
    
    if ~isempty(u_cent_epochs)
        
        all_edge = [all_edge; u_edge_epochs(k,:)];
        
    end

end

burst_right_state = find(intersect(all_edge(:,1), time_inds));

all_edge = all_edge(burst_right_state,:); % only keep bursts during desired state

% for k =
%     peakginfer
% end

end
    