%% BYCYCLE SPINDLE DETECTOR

function [st,trgh_times] = bycycle_spindle_detector(bycycle_params,lfp,states,fd,refch,manual_rej,Fs)

% SPIT OUT YO SPINDLE AND TROUGH TIMES!
% 
% Fs = 1000; manual_rej = 0;
% fd = 'C:\Users\Loomis\Documents\HO_FO_Spindles\Laminar1_PFC\2019-05-30_18-01-49\';

cd(fd)

tc = -lfp.trial{1}(refch,:);

save([fd '\lfp_spindref_raw.mat'],'tc')

% run spindle detector
system(['python C:\Users\Loomis\Documents\Scripts\spindle_detect_bycycle.py ' ['"' fd '\lfp_spindref_raw.mat"'] ' ' num2str(bycycle_params(1)) ...
    ' ' num2str(bycycle_params(2)) ' ' num2str(bycycle_params(3)) ' ' num2str(bycycle_params(4))])
% Import Table
spind_table=readtable([fd '\spindle_peaks.csv']);

trgh_times = spind_table.sample_peak;
% Get Burst true/false
brst = strcmpi(spind_table.is_burst,'True');
% use contiguous
trgh_inds = contiguous(brst,1);
trgh_inds = trgh_inds{1,2};
%get rid of spindles not in nrem
gs=time_STATE2gs(states(1).t);
strt_ind = spind_table.sample_peak(trgh_inds(:,1));
end_ind = spind_table.sample_peak(trgh_inds(:,2));
[~,g_spind_ind,~] = intersect(strt_ind,gs);
st = [strt_ind(g_spind_ind) end_ind(g_spind_ind)];

d = st(2:end,1)-st(1:(end-1),2);
d = find(d<=200);
st_s = st(:,1); st_e = st(:,2);
st_s(d+1) = []; st_e(d) = [];
st = [st_s st_e];

%now, plot spindles in pages of 8x8. let user input crap spindles.
if manual_rej
for k = 1 : ceil(size(st,1)./64)
    ns = ( (k-1)*64 + 1):(k * 64); 
%     if ns(end)>size(st,1)
%         ns = ( (k-1)*64 + 1):size(st,1); 
    ns_ind = 1;
    figure(k)
    for kk = 1 : 8
        for kkk = 1 : 8
            if ns(ns_ind)<= size(st,1)
            subplot(8,8,ns_ind);
            if (st(ns(ns_ind),1)-700) >= 1
                ll = (st(ns(ns_ind),1)-700);
            else
                ll = 1;
            end
            if (st(ns(ns_ind),2)+700) <= length(lfp.trial{1})
                ul = (st(ns(ns_ind),2)+700);
            else
                ul = length(tc.trial{1});
            end
            t = ll : ul; t = t ./ Fs;
            plot(t,lfp.trial{1}(refch,ll:ul));
            hold on
            t2 = (ll+700):(ul-700); t2 = t2./Fs;
            plot(t2,lfp.trial{1}(refch,(ll+700):(ul-700)),'r');
            title(ns(ns_ind))
            else
                break
            end
            ns_ind = ns_ind+1;
        end
    end
end

bi = input('which spindles are bad?');

st(bi,:) = [];
end

%IMPORTANT
save([fd '\bycycle_spindledetect_out.mat'],'st','trgh_times')
end