%% run spindle detection
function [spindle_times] = checkSpindlesv2(lfp_temp,Fs,lfreq,hfreq,gsamps,pk_thr)

addpath(genpath('C:\Users\Loomis\Documents\Packages\SharedSpectralAnalysisforZip'))

winSize=10;

winStepSize=winSize./2;

 % next spindle % mil - appears to be d
 
  % prev spindle % mil - appears to be a

  % remove spindle % mil - appears to be a w
         
   % add spindle % mil - CHANGED TO S
  
   % x , exit mil - this is right
   
   % click left/right below y=0 to modify spindle start/stop
   
%  lfp_temp = detrend(lfp_temp);
%  mu = mean(lfp_temp); sigma = std(lfp_temp); Z = 4;
%  idx = (abs(lfp_temp) - mu > Z*sigma );
%  lfp_temp(idx) = 0;
  lfp = lfp_temp;

% default valuse for non-data inputs
if length(Fs) < 1
    Fs= 1.0173e+003; % for mua 1/bin
end
lfpTime=(1:length(lfp.trial{1}))./Fs;
if length(lfreq) < 1
    lfreq=9;
end
if length(hfreq) < 1
    hfreq=17;
end
spindle_times = findspindlesv5(lfp,Fs,lfreq,hfreq,gsamps,pk_thr);
spindle_times = spindle_times(:,1:2);
% bsamps=1:length(lfp_temp);
% bsamps(gsamps)=[];
% bi=[];
% for k=1:size(spindle_times,1)
%     if intersect(bsamps,(round(spindle_times(k,1)*Fs):round(spindle_times(k,2)*Fs)))
%         bi=[bi k];
%     end
% end
% spindle_times(bi,:)=[];

lfp = lfp.trial{1};

disp(strcat(num2str(size(spindle_times,1)),{' '},'putative spindles detected'))
disp(strcat('spindle density of',{' '}, num2str(60*size(spindle_times,1)./(length(gsamps)./Fs))))
%% filter lfp for display
disp('filtering lfp for display');
band=[.5 50];

n= ceil(6*(Fs/lfreq)); % minimum filter order
b=fir1(n, 2*band./Fs,blackman(n+1));
lfp_filt= filtfilt(b,1,lfp);

n= ceil(6*(Fs/lfreq)); % minimum filter order
b=fir1(n, 2*[9 16]./Fs,blackman(n+1));
lfp_spind_filt= filtfilt(b,1,lfp);
amp = abs(hilbert(lfp_spind_filt));
lfp_spind_filt = zscore(lfp_spind_filt);
amp = zscore(amp);

%lfp_filt=lfp;

s_n=1;
scr_n=1;
scroll_times = round(mean(spindle_times,2));
%scroll_times = gsamps((winStepSize*Fs):(winStepSize*Fs):end);
scroll_times(scroll_times<=round(Fs*(winSize/2)))=[];
     %%
     run=1;

     while run
%           try
         if scr_n > length(scroll_times)
             run=0;
             disp('end of the line!')
             break
         end
         
         plot_from=scroll_times(scr_n)-round(Fs*(winSize/2));
         plot_to=scroll_times(scr_n)+round(Fs*(winSize/2));
         
         figure(1); clf; 
       
         
         subplot(5,1,[1]); hold on
        [~,f,t,pc,~,~] = spectrogram(lfp(plot_from:plot_to),round(2*Fs),round(1.9*Fs),[],Fs);
        
        title(strcat('frame',{' '},num2str(scr_n),{' '},'out of',{' '},num2str(length(scroll_times))))
        
        [~,fl] = min(abs(f-5));
        
        [~,fu] = min(abs(f-25));
        
         pwscl = pc(fl:fu,:); pwscl=max(pwscl(:));
        
         imagesc(lfpTime(plot_from)+t,f,pc,[0 pwscl]);
         %imagesc(lfpTime(plot_from)+t,f,pc);
         %xlim([min(t)-winsize/2 max(t)+winsize/2]);
         ylim([0 20]);
         line([lfpTime(plot_from),lfpTime(plot_to)],[lfreq lfreq],'Color','r')
         line([lfpTime(plot_from),lfpTime(plot_to)],[hfreq hfreq],'Color','r')
         
         xl = [lfpTime(plot_from) lfpTime(plot_to)];
         
         xlim(xl);
         subplot(5,1,[2 3]); hold on
         
         %xlim([spindle_times{ch}(s_n,1)-5 spindle_times{ch}(s_n,2)+5]');
         
         xlim(xl);
         
         %text(spindle_times(s_n,1)-4,-2300,'click here to move spindle boundaries (left for tart right for end)');
         
         plot(lfpTime(plot_from:plot_to),lfp(plot_from:plot_to))
         vline(spindle_times(scr_n,1)./Fs), vline(spindle_times(scr_n,2)./Fs)
         plotvert_thick(spindle_times(s_n,:)','k',0.8);
         plot(lfpTime(plot_from:plot_to),lfp(plot_from:plot_to))
         
         % bottom line
         plot(xl,[1 1].*0,'b');
         
         
                  %plot some spindles around the current one
         sni = round(mean(spindle_times,2)); sni = find(abs(sni-mean([plot_from plot_to]))<=(15*Fs));
         for ni=1:length(sni)
             n=sni(ni);
             vline(spindle_times(scr_n,1)./Fs), vline(spindle_times(scr_n,2)./Fs)
             plotvert_thick(spindle_times(n,:)','k',0.8);
         end;
         
         subplot(5,1,4)
         plot(lfpTime(plot_from:plot_to),lfp_spind_filt(plot_from:plot_to)), hold on
         plot(lfpTime(plot_from:plot_to),amp(plot_from:plot_to))
         box off
         xlim(xl);
         
         stmp = lfp(spindle_times(scr_n,1):spindle_times(scr_n,2));
         pw=fft(stmp);
         pw = abs(pw(1:((length(stmp)/2)+1)));
         fx = Fs*(0:(length(stmp)/2))./length(stmp);
         
         subplot(5,2,9)
         plot(fx,pw), xlim([2 25])
         [~,llth] = min(abs(fx-3)); [~,ulth] = min(abs(fx-7));
         thp = mean(pw(llth:ulth));
         [~,llsp] = min(abs(fx-9)); [~,ulsp] = min(abs(fx-17));
         spp = mean(pw(llsp:ulsp));
         title(spp / thp)
         subplot(5,2,10)
         plot(lfpTime, lfp), hold on, plot(round(spindle_times(scr_n,1)./Fs), lfp(round(spindle_times(scr_n,1)./Fs)), 'r*')
         
         [x,y,b]=ginput(1);
         
         %scrolling inputs...
         if b==100 % f - next spindle % mil - appears to be d
             scr_n= scr_n+1;
             disp('next spindle');
         end;
         if b==97 % d - prev spindle % mil - appears to be a
             scr_n= scr_n-1;
             scr_n=max(scr_n,1);
             disp('prev. spindle');
         end;
         
         %
         if b==119 % r - remove spindle % mil - appears to be a w
             [~,s_n] = min(abs(x-mean(spindle_times,2)));
              spindle_times(s_n,:)=[];
             disp('removed spindle');
         end;
         
         
         if b==115 % S - add spindle
             disp('new spindle');
             %text(spindle_times(s_n,1)-4,3000,'click on start','Background',[1 .7 .7]); drawnow;
             [x,~,~]=ginput(1);
             
             %vline(x); drawnow;
             plotvert_thick(x,'k',0.5); drawnow;
             spindle_times(end+1,1)=x;
             
             %text(spindle_times(s_n,1)-4,3000,'click on end','Background',[1 .7 .7]);drawnow;
             
             [x,~,~]=ginput(1);
             %vline(x); drawnow;
             plotvert_thick(x,'k',0.5); drawnow;
             spindle_times(end,2)=x;
             
             
             [~,ii]=sort(spindle_times(:,1)); % sort by start times
              spindle_times(:,1)=spindle_times(ii,1);
              spindle_times(:,2)=spindle_times(ii,2);
              
         end;
         
         if (y<-0)
             [~,s_n] = min(abs(x-mean(spindle_times,2)));
             if b==1 % left
                 spindle_times(s_n,1)=x;
             end;
             if b==3 % right
                 spindle_times(s_n,2)=x;
             end;
             
         end;
         
         if b==106 % x , mil - this is j
             scr_n = input('jump to frame?');
         end;
         
         if b==120 % x , mil - this is right
             run=0;
             disp('exited, data not saved yet!');
         end;
%          catch
%              disp('there was a whoopsie, here are your spindle times')
%              return
%           end
     
end
end
%% save
% 
% save(sp_file,'spindle_times');
% save([sp_file,'_snapshot_',date],'spindle_times');
% disp(['spindle file saved in ',sp_file]);
% 
% %% add the spindle results into events
% 
%  %load epochs
% 
% load_initialize_epochs; % load or initialize epochs
% % spindles are id:10
% 
% for i=1:size(spindle_times{ch},1)
% 
%     epochs.data(end+1,1)=spindle_times{ch}(i,1);
%     epochs.data(end,2)=spindle_times{ch}(i,2);
%     epochs.data(end,3)=10;
%     
% end;
% 
% save(ep_file,'epochs');
% save([ep_file,'_spindle_review_snapshot_',date],'epochs');
% disp(['epoch file saved in ',ep_file]);



