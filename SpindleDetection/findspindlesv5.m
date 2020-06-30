function times_all = findspindlesv5(lfp,Fs,lfreq,hfreq,gs,pk_thr)

if isempty(pk_thr)
    pk_thr = 2.8;
end

% FILTER THAL LFP FOR SPINDLES

% default valuse for non-data inputs
if length(Fs) < 1
    Fs= 1000;%1.0173e+003; % for mua 1/bin
end
%lfpTime=(1:length(lfp))./Fs;
if length(lfreq) < 1
    lfreq=8.5;
end
if length(hfreq) < 1
    hfreq=17;
end

%%
lfpo = lfp;
cfg=[]; cfg.bpfilter='yes'; cfg.bpinstabilityfix='reduce'; cfg.bpfreq=[lfreq hfreq]; lfp = ft_preprocessing(cfg,lfp);

cfg=[]; cfg.hilbert='abs'; lfp = ft_preprocessing(cfg,lfp);
lfp.trial{1} = lfp.trial{1}.^2;

times_all = [];

for k = 1 : size(lfp.trial{1},1)

%lfp_filt = lfp_filt.^2; %MILAN COMMENTED THIS OUT
%lfp_filt = compress_sqrt(lfp_filt./3000).*1500; %3000 is taken based on a signal of 6000, which was the first example we used. This is just to make the input linear

env_smooth = lfp.trial{1}(k,:);

%%
% building filter to smooth the envelop

%env_smooth = env;

detector= (env_smooth > (median(env_smooth(gs)) + -.1*std(env_smooth(gs)))); %GV: .35

detector(1) = 0;
detector(end) = 0;

on_time = find(diff(detector) == 1);
off_time = find(diff(detector) == -1);


% select for nrem sleep times
mid_time = round((on_time + off_time) ./2);

[~,~,gspind_ind] = intersect(gs,mid_time);

on_time = on_time(gspind_ind); off_time = off_time(gspind_ind);

%check if spindles have a peak of 2.8 std
envz = median(env_smooth(gs))+pk_thr*std(env_smooth(gs)); %GV: 2.8
gi=[];
for i = 1 : length(on_time)
    st = max(env_smooth(round(on_time(i)):round(off_time(i))));
    if st>=envz
        gi = [gi i];
    end
end

on_time = on_time(gi); off_time = off_time(gi);
    
d = diff(on_time);
d = find(d<=100); % SEPARATING TIME BETWEEN SPINDLES

on_time(d+1) = []; off_time(d)=[];

%check if spindles are at least X seconds long
times=[];
n_spindles = 0;
for inpt = 1:length(on_time); %cycling through the on_times as content. Another way to do this is to do i = 1:length(on_times) and t = on_times(i);
    t = on_time(inpt);
    next_off = min(off_time(find(off_time > t)));
  if (next_off - t) > (300) & (next_off -t) <(8000)
      n_spindles = n_spindles + 1;
      times(n_spindles, 1) = t;
      times(n_spindles, 2) = next_off;

      
      %plot(t,10000,'ro');
      %plot(next_off,10000,'bo');
  end
end

spindrat=[];
for spindpw = 1 : size(times,1)
    % take fft
    stmp = lfpo.trial{1}(k,times(spindpw,1):times(spindpw,2));
    pw=fft(stmp);
    pw = abs(pw(1:((length(stmp)/2)+1)));
    fx = Fs*(0:(length(stmp)/2))./length(stmp);
    [~,llth] = min(abs(fx-3)); [~,ulth] = min(abs(fx-8)); % GV: 8
    thp = mean(pw(llth:ulth));
    [~,llsp] = min(abs(fx-9)); [~,ulsp] = min(abs(fx-17));
    spp = mean(pw(llsp:ulsp));
    spindrat(spindpw) = spp / thp;
    % find theta spind ratio
    % make sure it exceeds threshold
    % if not add to bad inds
end
%get rid of spindles below threshold

times(spindrat<=0,:) = []; %GV: .6

times = cat(2,times,ones(size(times,1),1).*k);
%times_all{k} = times;

times_all = [times_all; times];

end

end

% dirsave=strcat([maindir directory day '/matlab/FiltelecA2_6to15']);
% save (dirsave, 'filteredlfp');
