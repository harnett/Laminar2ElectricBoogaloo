function [wxa,wva] = GLMSpindlePark(lfp,unitdata,st,good_ctx_th_ch,trialIndices)%st unitdata lfp
addpath(genpath('C:\Users\Loomis\Documents\Scripts\neuroGLM-master'))
for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end
rawData.nTrials = size(st,1);
[dn,~] = binspikes(spk,1000); dn(dn>1) = 1;
dn = dn';
ncells = size(dn,1);
% for each spindle...
for k = 1 : size(st,1)
% get lfp
gs = st(k,1):st(k,2);
rawData.trial(k).LFP = lfp.trial{1}(good_ctx_th_ch(1),gs);
rawData.trial(k).duration = length(gs);
% get spiketimes for taht spindle
dns = dn(:,gs);
% loop thru each spike, add to that trial
for kk = 1 : size(dns,1)
    spkt = find(dns(kk,:));
    rawData.trial(k).(['sptrain' num2str(kk)]) = spkt;
end
end
nTrials = size(st,1); % number of trials
unitOfTime = 'ms';
binSize = 1; % TODO some continuous observations might need up/down-sampling if binSize is not 1!?

param.samplingFreq = 1;

%% Specify the fields to load
expt = buildGLM.initExperiment(unitOfTime, binSize, [], param);
% expt = buildGLM.registerContinuous(expt, 'LFP', 'Local Field Potential', 1); % continuous obsevation over time

for k = 1 : ncells
expt = buildGLM.registerSpikeTrain(expt, ['sptrain' num2str(k)], ['neuron' num2str(k)]); % Spike train!!!
end
%% Convert the raw data into the experiment structure

expt.trial = rawData.trial;
%verifyTrials(expt); % checks if the formats are correct

%% Build 'designSpec' which specifies how to generate the design matrix
% Each covariate to include in the model and analysis is specified.
dspec = buildGLM.initDesignSpec(expt);
binfun = expt.binfun;


% bs = basisFactory.makeSmoothTemporalBasis('boxcar', 50, 10, binfun);
% bs.B = 0.1 * bs.B;
% 
% %% Instantaneous Raw Signal without basis
% dspec = buildGLM.addCovariateRaw(dspec, 'LFP', [], bs);

%% Spike history
for k = 1 : ncells
dspec = buildGLM.addCovariateSpiketrain(dspec, ['spk' num2str(k)], ['sptrain' num2str(k)], ['History/Coupling filter' num2str(k)]);
end
%% Compile the data into 'DesignMatrix' structure
if isempty(trialIndices)
trialIndices = 1:(nTrials); %(nTrials-1); % use all trials except the last one
end
dm = buildGLM.compileSparseDesignMatrix(dspec, trialIndices);

%% Visualize the design matrix
endTrialIndices = cumsum(binfun([expt.trial(trialIndices).duration]));
X = dm.X(1:endTrialIndices(3),:);
mv = max(abs(X), [], 1); mv(isnan(mv)) = 1;
X = bsxfun(@times, X, 1 ./ mv);
%figure(742); clf; %imagesc(X);
%buildGLM.visualizeDesignMatrix(dm, 1); % optionally plot the first trial
%% Do some processing on the design matrix
dm = buildGLM.removeConstantCols(dm);
% colIndices = buildGLM.getDesignMatrixColIndices(dspec, 'LFP');
% dm = buildGLM.zscoreDesignMatrix(dm, [colIndices{:}]);

dm = buildGLM.addBiasColumn(dm); % DO NOT ADD THE BIAS TERM IF USING GLMFIT

% wxa = nan(ncells,13,ncells);
% wva = nan(ncells,13,ncells);
%% Get the spike trains back to regress against
for cell_num = 1 : ncells
ys{cell_num} = buildGLM.getBinnedSpikeTrain(expt, ['sptrain' num2str(cell_num)], dm.trialIndices);
end

[wx,wv] = glm_loop(dm,ys{1},ncells,dspec);
wxa = nan(ncells,length(wx),ncells); wva = wxa;
wxa(:,:,1) = wx;
wva(:,:,1) = wv;

parfor cell_num = 2 : ncells % CAN PARFOR
    disp([num2str(cell_num) ' done out of ' num2str(ncells)])
[wx,wv] = glm_loop(dm,ys{cell_num},ncells,dspec);
wxa(:,:,cell_num) = wx;
wva(:,:,cell_num) = wv;
end
% 
% %% Get the spike trains back to regress against
% y = buildGLM.getBinnedSpikeTrain(expt, 'sptrain1', dm.trialIndices);
% 
% %% Do some processing on the design matrix
% dm = buildGLM.removeConstantCols(dm);
% % colIndices = buildGLM.getDesignMatrixColIndices(dspec, 'LFP');
% % dm = buildGLM.zscoreDesignMatrix(dm, [colIndices{:}]);
% 
% dm = buildGLM.addBiasColumn(dm); % DO NOT ADD THE BIAS TERM IF USING GLMFIT
% 
% 
% 
% %% Least squares for initialization
% tic
% wInit = dm.X \ y;
% toc
% 
% %% Use matRegress for Poisson regression
% % it requires `fminunc` from MATLAB's optimization toolbox
% %addpath('matRegress')
% 
% fnlin = @nlfuns.exp; % inverse link function (a.k.a. nonlinearity)
% lfunc = @(w)(glms.neglog.poisson(w, dm.X, y, fnlin)); % cost/loss function
% 
% opts = optimoptions(@fminunc, 'Algorithm', 'trust-region', ...
%     'GradObj', 'on', 'Hessian','on');
% 
% [wml, nlogli, exitflag, ostruct, grad, hessian] = fminunc(lfunc, wInit, opts);
% wvar = diag(inv(hessian));
% 
% %% Alternative maximum likelihood Poisson estimation using glmfit
% % [w, dev, stats] = glmfit(dm.X, y, 'poisson', 'link', 'log');
% % wvar = stats.se.^2;
% 
% %% Visualize
% ws = buildGLM.combineWeights(dm, wml);
% wvar = buildGLM.combineWeights(dm, wvar);
% end

% 
% fig = figure(2913); clf;
% nCovar = numel(dspec.covar);
% for kCov = 1:nCovar
%     label = dspec.covar(kCov).label;
%     subplot(nCovar, 1, kCov);
%     errorbar(ws.(label).tr, ws.(label).data, sqrt(wvar.(label).data));
%     title(label);
% end
% 
% % return % ???
% 
% % {
% % % Specify the model
% % hasBias = true;
% % model = buildGLM.buildModel(dspec, 'Poisson', 'exp', hasBias);
% % % Do regression
% % [w, stats] = fitGLM(model, dm, y);
% % }
% 
% %% Visualize fit
% visualizeFit(w, model, dspec, vparam(1)); % ???
% 
% %% Simulate from model for test data
% testTrialIndices = nTrial; % test it on the last trial
% dmTest = compileSparseDesignMatrix(expt, dspec, testTrialIndices);
% 
% yPred = generatePrediction(w, model, dmTest);
% ySamp = simulateModel(w, model, dmTest);
% 
% %% Validate model
% gof = goodnessOfFit(w, stats, model, dmTest);
% visualizeGoodnessOfFit(gof);
end