
function [sps,pGLMconst2,pGLMhistfilts2,ratepred2,pGLMconst1,pGLMhistfilt1,ratepred1,spm,gu] = glmCoupled_TCOnly(unitdata,chs,tl,gs,nthist,dTSpk,MaxIter)
% 
% clear
% 
% load('unitdata')
% 
% chs = 1:131;
% 
% %chs = find(vertcat(unitdata(:).fsrs)==1);
% 
% %chs=chs(1:2:end);
% 
% %ts = Y; % good ms long samples
% tl = []; % tl = [300 900]time lim in seconds
% gs=[100000:180000];
% nthist = 5;
% 
% dTSpk = .001;
% 
% MaxIter = 40;
% 
if isempty(chs)
    chs = 1 : length(unitdata);
end
ncells = length(chs);

a = cell(1,length(unitdata));
for ui = 1 : length(unitdata)
    a{ui} = unitdata(ui).area;
end

if length(gs)>=(20*1000*60)
    gs = gs(1:20*1000*60);
end
% dtStim = dTSpk; % time bin size for stimulus (s)

% See tutorial 1 for some code to visualize the raw data!

%% ==== 2. Bin the spike trains =========================
%
% For now we will assume we want to use the same time bin size as the time
% bins used for the stimulus. Later, though, we'll wish to vary this.
if ~isempty(tl)
tbins = tl(1):dTSpk:tl(2);
tbins = mean([tbins; (tl(1)+dTSpk):dTSpk:(tl(2)+dTSpk)])';% time bin centers for spike train binnning
else
    for jj = 1:ncells
    stm(jj) = max(unitdata(chs(jj)).ts);
    end
    stm=max(stm);
    tbins=(0:dTSpk:stm)';
    %tbins = mean([tbins; dTSpk:dTSpk:(stm+dTSpk)])';
end
nT = size(tbins,1); % number of time bins in stimulus
sps = zeros(nT,ncells);
for jj = 1:ncells
    st = unitdata(chs(jj)).ts;
    if ~isempty(tl)
    gi1 = st(st>=tl(1)); gi2 = st(st<=tl(2));
    st = union(gi1,gi2);
    end
    sps(:,jj) = hist(st,tbins)';  % binned spike train
end
if ~isempty(tl)
tbins = tbins(2:(end-1));
sps=sps(2:(end-1),:);
else
    tbins_ms = round(tbins.*1000);
    [~,tbins_ind] = intersect(tbins_ms,gs);
    tbins = tbins(tbins_ind);
end
sps = sps(tbins_ind,:);
sps(sps>=1) = 1;
nT=size(tbins,1);
stimtimes = tbins;%[0:dTSpk:(nT)]';% stim frame times in seconds (if desired)

spm = sum(sps,1); spm = find(spm<=800); sps(:,spm) = []; ncells = size(sps,2); 

%% === 4. fit single-neuron GLM with spike-history ==================

% First fit GLM with no spike-history
% fprintf('Now fitting basic Poisson GLM...\n');
% pGLMwts0 = glmfit(Xstim,sps(:,cellnum),'poisson'); % assumes 'log' link and 'constant'='on'.
% pGLMconst0 = pGLMwts0(1);
% pGLMfilt0 = pGLMwts0(2:end);

% Then fit GLM with spike history (now use Xdsgn design matrix instead of Xstim)
fprintf('Now fitting Poisson GLM with spike-history...\n');
pGLMconst1=nan(1,ncells);
pGLMhistfilt1=nan(nthist,ncells);
ratepred1=nan(size(sps,1),size(sps,2));

o=statset('glmfit');
o.MaxIter=MaxIter;

for k = 1 : ncells
    tic
    % Build spike-history design matrix
paddedSps = [zeros(nthist,1); sps(1:end-1,k)];
% SUPER important: note that this doesn't include the spike count for the
% bin we're predicting? The spike train is shifted by one bin (back in
% time) relative to the stimulus design matrix
Xdsgn = hankel(paddedSps(1:end-nthist+1), paddedSps(end-nthist+1:end));
%disp(checkGLMTol(Xdsgn,sps(:,k),'poisson'))
[pGLMwts1] = glmfit(Xdsgn,sps(:,k),'poisson','Options',o);
%disp(iter)
pGLMconst1(k) = pGLMwts1(1);
pGLMhistfilt1(:,k) = pGLMwts1(2:end);
ratepred1(:,k) = exp(pGLMconst1(k) + Xdsgn*pGLMwts1(2:end));
t_sh(k,1)=toc;
disp(k)
disp(toc)
end

k=kmeans(t_sh,2);
m1=mean(t_sh(find(k==1)));
m2=mean(t_sh(find(k==2)));
[~,m] = min([m1 m2]); 
if m==1
    gu=find(k==1);
elseif m==2
    gu=find(k==2);
end
ncells = length(gu);
sps = sps(:,gu);

a = a(gu);
ThChs = union(find(strcmp(a,'MD')),find(strcmp(a,'MGB')));
CtxChs = union(find(strcmp(a,'PFC')),find(strcmp(a,'A1')));

%% === 5. fit coupled GLM for multiple-neuron responses ==================

% First step: build design matrix containing spike history for all neurons

Xspall = zeros(nT,nthist,ncells); % allocate space
% Loop over neurons to build design matrix, exactly as above
for jj = 1:ncells
    paddedSps = [zeros(nthist,1); sps(1:end-1,jj)];
    Xspall(:,:,jj) = hankel(paddedSps(1:end-nthist+1),paddedSps(end-nthist+1:end));
end

% Reshape it to be a single matrix
Xdsgn2 = reshape(Xspall,nT,[]);

%% Fit the model (stim filter, sphist filter, coupling filters) for one neuron 

fprintf('Now fitting Poisson GLM with spike-history and coupling...\n');

for k = 1 : ncells
    tic
    if ismember(k,CtxChs)
        Xspall_tmp = Xspall(:,:,[ThChs k]);
    else
        Xspall_tmp = Xspall(:,:,[CtxChs k]);
    end
    
    Xdsgn2 = reshape(Xspall_tmp,nT,[]);
    pGLMwts2 = glmfit(Xdsgn2,sps(:,k),'poisson','Options',o);
    pGLMconst2(k) = pGLMwts2(1);
    pGLMhistfilts2tmp = pGLMwts2(2:end);
    pGLMhistfilts2vec{k} = pGLMhistfilts2tmp;
    if ismember(k,CtxChs)
    pGLMhistfilts2{k} = reshape(pGLMhistfilts2tmp,nthist,length([ThChs k]));
    else
    pGLMhistfilts2{k} = reshape(pGLMhistfilts2tmp,nthist,length([CtxChs k]));
    end
    ratepred2{k} = exp(pGLMconst2(k) + Xdsgn2*pGLMhistfilts2vec{k});
    toc
    disp(k)
end
%% Compute predicted spike rate on training data
