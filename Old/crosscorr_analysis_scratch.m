clear
load('XCorr_ThalamoCort_AllState_All.mat')
xs = max(xca,[],2);
xca(xs<20,:) = []; aa(xs<20) = [];
w = gausswin(500,17.82); % we want sig to be 7 ms (14 bins), sig = (L-1)/(2a), so a = (L-1)/(2*sig) = 499/(2*14) = 17.82
w=w./sum(w);
xcapred = conv2(1,w,xca,'same');
cch_prob = 1 - poisscdf(xca,xcapred);
win = (-.050:.0005:.050);
% [~,li] = min(abs(win-.001));
% [~,ui] = min(abs(win-.01));
[~,li] = min(abs(win-.015));
[~,ui] = min(abs(win+.015));
lui = [li ui]; lui = sort(lui); li = lui(1); ui = lui(2);
cch_prob = 1 - poisscdf(xca,xcapred);
sigflag = zeros(1,size(cch_prob,1));
for k = 1 : size(cch_prob,1)
    
tmp = squeeze(cch_prob(k,li:ui));

tmp2 = zeros(1,length(tmp));
tmp2(tmp<=.05) = 1;

% if sum(tmp2)>=4
%     sigflag(k) = 1;
% end

if max(tmp2)==1
%find contiguous blocks of X within 1.5-4ms away from 0
runs = contiguous(tmp2,1); runs=runs{1,2}; runs=runs(:,2)-runs(:,1);
%if found, set sigflag to 1
if max(runs)>=2
sigflag(k) = 1;
end
end

end
xcs = xca(find(sigflag),:); aa = aa(find(sigflag));

%imagesc(zscore(xcs,[],2))
cch_prob = cch_prob(find(sigflag),:);
[xmi] = min(cch_prob(:,li:ui),[],2);
[~,xmi] = sort(xmi);

xcs = xcs(xmi,:); aa = aa(xmi);

for k = 1 : 55
subplot(7,8,k)
plot(xcs(k,:)), title([aa(k) find(xcs(k,:)==max(xcs(k,:)))])
end

imagesc(zscore(xcs(xmi,:),[],2))
[xm] = max(xca,[],2)-min(xca,[],2);
[~,xm] = sort(xm);
xm = flipud(xm);
xca = xca(xm,:);
imagesc(xca)
cch_prob = cch_prob(xm,:);

%%

% get proportion of TC, CT Xcorrs out of possible for each area
load('XCorr_ThalamoCort_All_nrem.mat')
a = xcsiga;
load('XCorr_ThalamoCort_All_rem.mat')
b = xcsiga;
load('XCorr_ThalamoCort_All_wake.mat')
c = xcsiga;
xc = [a b c];
md_xc = xc(find(aa==1),:);
mgb_xc = xc(find(aa==0),:);
md_xc(md_xc==2)=0;
mgb_xc(mgb_xc==2)=0;
md_xc(md_xc==3)=1;
mgb_xc(mgb_xc==3)=1;
mean(md_xc).*100
mean(mgb_xc).*100
%%
xc = [a b c];
md_xc = xc(find(aa==1),:);
mgb_xc = xc(find(aa==0),:);
md_xc(md_xc==1)=0;
mgb_xc(mgb_xc==1)=0;
md_xc(md_xc==2)=1;
mgb_xc(mgb_xc==2)=1;
md_xc(md_xc==3)=1;
mgb_xc(mgb_xc==3)=1;
mean(md_xc).*100
mean(mgb_xc).*100