function times = findspindlesv4(lfp,Fs,lfreq,hfreq,gs)

% FILTER THAL LFP FOR SPINDLES

% default valuse for non-data inputs
if length(Fs) < 1
    Fs= 1.0173e+003; % for mua 1/bin
end
lfpTime=(1:length(lfp))./Fs;
if length(lfreq) < 1
    lfreq=10;
end
if length(hfreq) < 1
    hfreq=15;
end

%%

n= ceil(6*(Fs/lfreq)); % minimum filter order
% make sure n is even
if rem(n,2)==0
    n=n;
else % if not...
    n=n+1;
end

band=[lfreq hfreq];
b=fir1(n, 2*band./Fs,blackman(n+1));
lfp_filt= filtfilt(b,1,lfp);

%lfp_filt = lfp_filt.^2; %MILAN COMMENTED THIS OUT
%lfp_filt = compress_sqrt(lfp_filt./3000).*1500; %3000 is taken based on a signal of 6000, which was the first example we used. This is just to make the input linear

X = hilbert(lfp_filt); %analytic signal corresponding to real input signal x
env = abs(X); env = env./sum(env);
%%
% building filter to smooth the envelop
f = normpdf([-100:100], 0, Fs/6); %generating a guassian with specified parameters: array, mean and stdv 
f = f./sum(f); %normalization step
env_smooth = env;%conv(env,f,'same'); %convolution

%env_smooth = env;

detector= (env_smooth > (mean(env_smooth(gs)) + 1*std(env_smooth(gs))));

on_time = find(diff(detector) == 1);
off_time = find(diff(detector) == -1);

% select for nrem sleep times
mid_time = (on_time + off_time) ./2;

bi=[];
for k=1:size(mid_time,1)
    if ~intersect(gs,(mid_time(k)))
        bi=[bi k];
    end
end
on_time(bi)=[]; off_time(bi)=[];

%check if spindles have a peak of 2.7 std
envz = mean(env(gs))+3*std(env(gs));
gi=[];
for i = 1 : length(on_time)
    st = max(env_smooth(round(on_time(i)):round(off_time(i))));
    if st>=envz
        gi = [gi i];
    end
end

on_time = on_time(gi); off_time = off_time(gi);
    
d = diff(on_time);
d = find(d<=1000);

on_time(d+1) = []; off_time(d)=[];

on_time = lfpTime(on_time); off_time = lfpTime(off_time);

%check if spindles are at least X seconds long
times=[];
n_spindles = 0;
for inpt = 1:length(on_time); %cycling through the on_times as content. Another way to do this is to do i = 1:length(on_times) and t = on_times(i);
    t = on_time(inpt)
    next_off = min(off_time(find(off_time > t)));
  if (next_off - t) > (.4) & (next_off -t) <(4)
      n_spindles = n_spindles + 1;
      times(n_spindles, 1) = t;
      times(n_spindles, 2) = next_off;

      
      %plot(t,10000,'ro');
      %plot(next_off,10000,'bo');
  end
end

% dirsave=strcat([maindir directory day '/matlab/FiltelecA2_6to15']);
% save (dirsave, 'filteredlfp');
