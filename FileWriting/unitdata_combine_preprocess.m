function u1 = unitdata_combine_preprocess(u1,u2)

if isfield(u1,'ch')
[u1ch,so]=sort(vertcat(u1(:).ch));
u1 = u1(so);
else
    [u1ch,so]=sort(vertcat(u1(:).tetrode));
    u1 = u1(so);
end

if ~isempty(u2)

u1cls=find(u1ch>=30);

[u2ch,so]=sort(vertcat(u2(:).ch));
u2 = u2(so);

u2cls=find(u2ch<=3);

if ~isempty(u1cls) && ~isempty(u2cls)

for u = 1 : length(u1cls)
spk1(u).time = u1(u1cls(u)).ts;
end
for u = 1 : length(u2cls)
spk2(u).time = u2(u2cls(u)).ts;
end
dn=binspikes([spk1 spk2],1000);
dn1=dn(:,1 : length(u1cls));
dn2=dn(:,(length(u1cls)+1) : end);
clear dn
% cc = zeros(size(dn1,2),size(dn2,2));
% cc_st=cc;
% for k = 1 : length(u1cls)
%     for kk = 1 : length(u2cls)
%         %correlate the 2 spike trains
%         cc_st(k,kk) = corr(dn1(:,k),dn2(:,kk));
%         %correlate the 2 waveforms
%         cc(k,kk) = corr(zscore(u1(u1cls(k)).waveform_mean(u1(u1cls(k)).ch,:)'),zscore(u2(u2cls(kk)).waveform_mean(u2(u2cls(kk)).ch,:)'));
%     end
% end
ind=1;
for k = 1 : length(u1cls)
    for kk = 1 : length(u2cls)
        figure(1)
        subplot(length(u1cls),length(u2cls),ind);
        plot(zscore(u1(u1cls(k)).waveform_mean(u1(u1cls(k)).ch,:)')), hold on, plot(zscore(u2(u2cls(kk)).waveform_mean(u2(u2cls(kk)).ch,:)'))
        figure(2)
        subplot(length(u1cls),length(u2cls),ind);
        plot(xcorr(dn1(:,k),dn2(:,kk),400))
        title([length(spk1(k).time) length(spk2(kk).time)])
        ind=ind+1;
    end
end

x = input('any overlapping units? u1 first, then u2');

if ~isempty(x)
badunit1=[]; badunit2=[];
for k = 1 : size(x,1)
    y=input(['for this unit pair, which one do i reject? u1 or u2? ' num2str([x(k,1) x(k,2)])]);
    if y==1
        badunit1 = [badunit1 u1cls(x(k,1))];
    elseif y==2
        badunit2 = [badunit2 u2cls(x(k,2))];
    end
end

u1(badunit1)=[]; u2(badunit2)=[];
end
end
% now merge u2 onto u1

for k = 1 : length(u2)
    u2(k).ch = u2(k).ch + 32;
    u1(length(u1)+1) = u2(k);
end

clear u2

end

wm=[]; wmtmp=[];
if isfield(u1,'ch')
for k = 1 : length(u1)
    if u1(k).ch<=32
        wmtmp = u1(k).waveform_mean(u1(k).ch,:);
    else
        wmtmp = u1(k).waveform_mean(u1(k).ch-32,:);
    end
    if wmtmp(length(wmtmp)./2)<=0
        wmtmp = -wmtmp;
    end
    wmtmp = wmtmp-mean(wmtmp);
    wm = [wm; wmtmp]; 
end
else
    for k = 1 : length(u1)
    [~,mwi] = max(max(abs(u1(k).waveform_mean),[],2));
    wm = [wm; u1(k).waveform_mean(mwi,:)];
    end
end
% do check for bad units
% do this by finding units with waveforms
% which are euclidean distant from others,
% plotting the potentially bad waveform
% and then letting the user decide to
% reject or nah

% y=pdist(zscore(wm,[],2));
% ym=mean(squareform(y));
% ythr = mean(ym) + 2.7 * std(ym);
% 
% bad_unit = find(ym>ythr);
% 
% bad_unit_conf=[];
% 
% if ~isempty(bad_unit)
%     for k = 1 : length(bad_unit)
%         figure(3)
%         plot(wm(bad_unit(k),:))
%         x = input('is this a bad cell? 1 for bad cell 0 for nah');
%         bad_unit_conf = [bad_unit_conf x];
%     end
% end
% 
% u1(bad_unit(find(bad_unit_conf)))=[];
% wm(bad_unit(find(bad_unit_conf)),:)=[];
figure
for k = 1 : size(wm,1)
    subplot(10,10,k)
    plot(wm(k,:)), title(k)
end
figure
for k = 1 : size(wm,1)
    subplot(10,10,k)
    HistISIMilan(u1(k).ts,'k'), title(k)
end


x = input('any bad waveforms? input them. speak now or forever hold your peace.');

u1(x)=[];
wm(x,:)=[];

% now do preliminary fs/rs discrimination
% sort on multiple criteria
% save what each metric classifies each cell as, use best 2/3 (or whatevs)
% to say RS or FS

fr=[]; for k = 1 : length(u1)
fr = [fr length(u1(k).ts)./(max(u1(k).ts)-min(u1(k).ts))];
end

[mini,minind]=min(zscore(wm,[],2),[],2);
[maxi,maxind]=max(zscore(wm,[],2),[],2);

p2t_time = abs(maxind-minind);
p2t_amp = abs(maxi-mini);

idxtmp=[];
for nr = 1 : 51

    %k-means on z-scored waveforms
[idx1,ctmp] = kmeans(zscore(wm,[],2),2);
c1(1) = mean(abs(ctmp(1,:))); c1(2) = mean(abs(ctmp(2,:)));
idx1=idx1+1; idx1(idx1==2)=-1; idx1(idx1==3)=1;

if c1(1) > c1(2)
    idx1=-idx1;
end

%peak 2 trough time
bi = p2t_time>=60; gi = 1:length(p2t_time); gi(bi)=[];

[idx2_tmp,c2] = kmeans(p2t_time(gi),2);

%fix outliers
idx2 = zeros(length(p2t_time),1); idx2(gi) = idx2_tmp+1; idx2(idx2==2)=-1; idx2(idx2==3)=1;

if c2(1) > c2(2)
    idx2=-idx2;
end

idx2(bi) = 1;

%peak2trough amplitude

[idx3,c3] = kmeans(p2t_amp,2);

idx3=idx3+1; idx3(idx3==2)=-1; idx3(idx3==3)=1;

if c3(2) > c3(1)
    idx3=-idx3;
end

idxtmp2 = [idx1 idx2 idx3]; idxtmp2=-idxtmp2;
idxtmp = cat(3,idxtmp,idxtmp2);
end

idx = squeeze(sum(idxtmp,3));

fsrs=-sign(sum(idx'));

figure
for k = 1 : 12
t=tsne(zscore(wm,[],2));
subplot(4,3,k)
gscatter(t(:,1),t(:,2),fsrs)
end

figure
for k = 1 : size(wm,1)
subplot(10,10,k), if fsrs(k)==1, plot(zscore(wm(k,:)),'b'), hold on, else, plot(zscore(wm(k,:)),'r'), hold on
end, title([k fr(k)])
if k==1
	title([ k fr(k) ' blue is 1 (rs) red is -1 (fs)'])
end
end
figure
for k = 1 : size(wm,1)
    subplot(10,10,k)
    if fsrs(k)==1
        HistISIMilan(u1(k).ts,'b');
    else
        HistISIMilan(u1(k).ts,'r');
    end
    title(k)
end
x = input('any fs/rs cells misclassified? enter them');

fsrs(x) = -fsrs(x);

% -1 for FS 1 for RS

for k = 1 : length(u1)
    u1(k).fsrs = fsrs(k);
end

end
