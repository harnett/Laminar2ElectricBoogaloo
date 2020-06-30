clear
load('LFP_1k.mat')
load('States.mat')
%%
amp_fr = [.5 .6 .7];
amp_con = [.2 .3 .4 .5];
per_con = [.3 .4 .5];
mon_thr=[.5 .6 .7];
num_spind = nan(length(amp_fr),length(amp_con),length(per_con),length(mon_thr)); 
f='C:\Users\Loomis\Documents\HO_FO_Spindles\Laminar1_PFC\2019-06-01_14-20-40';
spind_avg = nan(length(amp_fr),length(amp_con),length(per_con),length(mon_thr),3000); 
spnd_all = {};
% iterate thru all different parameter combos
iter = 1;
for k = 1 : length(amp_fr)
    for kk = 1 : length(amp_con)
        for kkk = 1 : length(per_con)
            for kkkk = 1 : length(mon_thr)
                % detect spindles
                [st,tr]=bycycle_spindle_detector([amp_fr(k) amp_con(kk) per_con(kkk) mon_thr(kkkk)],lfp,states,f,64,0,1000);
                % get number detected
                if ~isempty(st)
                    num_spind(k,kk,kkk,kkkk) = size(st,1);
                    % segment lfp data
                    % average spindle
                    [spnd_aligned_cent,~,~] = lfp_spind_align(lfp.trial{1}(64,:),st,tr);
                    spnd_all{k,kk,kkk,kkkk} = spnd_aligned_cent;
                    spind_avg(k,kk,kkk,kkkk,:) = nanmean(spnd_aligned_cent);
                end
                
            disp(['iter ' num2str(iter)])
            iter = iter + 1;
            end
        end
    end
end
