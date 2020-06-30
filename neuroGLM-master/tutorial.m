%% Load the raw data
clear
for state = 1 : 3
    clear trl spk ys
load('unitdata')
load('states.mat')
wxa=[];

gsa = time_STATE2gs(states(state).t);
for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end
[dn,~] = binspikes(spk,1000); dn(dn>1) = 1;
if max(gsa)>length(dn)
    dn = [dn; zeros((max(gsa)-length(dn)),size(dn,2))];
    %gsa = gsa(1:(end-5));
end
gu = find(sum(dn(gsa,:),1)>=4000);
unitdata = unitdata(gu);
% clear gsa dn t spk

gepochs = states(1).t;
nTrials = length(gepochs);
unitOfTime = 'ms';
binSize = 1; % TODO some continuous observations might need up/down-sampling if binSize is not 1!?
param.samplingFreq=1;
ncells = length(unitdata);
%% Specify the fields to load
expt = buildGLM.initExperiment(unitOfTime, binSize, [], param);
%expt = buildGLM.registerContinuous(expt, 'LFP', 'Local Field Potential', 1); % continuous obsevation over time

for k = 1 : length(unitdata)
    spknm = ['sp' num2str(k)];
    expt = buildGLM.registerSpikeTrain(expt, spknm, 'spikes yo'); % Spike train!!!
end

%% Convert the raw data into the experiment structure
for g = 1 : nTrials
    gs=gepochs{g};
    trl(g).duration = length(gs);
for k = 1 : length(unitdata)
    spknm = ['sp' num2str(k)];
    t=round(unitdata(k).ts.*1000); t = unique(t);
    t=intersect(gs,t); t = t - gs(1)+1;
    trl(g).(spknm)= t;
end
end
expt.trial = trl;
%verifyTrials(expt); % checks if the formats are correct

%%

%% Build 'designSpec' which specifies how to generate the design matrix
% Each covariate to include in the model and analysis is specified.
dspec = buildGLM.initDesignSpec(expt);
binfun = expt.binfun;
% bs = basisFactory.makeSmoothTemporalBasis('boxcar', 100, 10, binfun);
% bs.B = 0.1 * bs.B;
% 
% %% Instantaneous Raw Signal without basis
% dspec = buildGLM.addCovariateRaw(dspec, 'LFP', [], bs);
for k = 1 : ncells
    spknm = ['sp' num2str(k)];
    %% Spike history / coupling filter
    dspec = buildGLM.addCovariateSpiketrain(dspec, ['nrn' num2str(k)] , spknm, 'another coupling doe', basisFactory.makeNonlinearRaisedCos(10, dspec.expt.binSize, [0 8], 2));%normally 0-100, controls history filter length?
%     %% Coupling filter
%     dspec = buildGLM.addCovariateSpiketrain(dspec, 'coupling', spknm, ['Coupling from neuron ' num2str(k)]);
end

%% Compile the data into 'DesignMatrix' structure
trialIndices = 1:length(gepochs);%:10; %(nTrials-1); % use all trials except the last one
dm = buildGLM.compileSparseDesignMatrix(dspec, trialIndices);

%% Visualize the design matrix
% endTrialIndices = cumsum(binfun([expt.trial(trialIndices).duration]));
% X = dm.X(1:endTrialIndices(3),:);
% mv = max(abs(X), [], 1); mv(isnan(mv)) = 1;
% X = bsxfun(@times, X, 1 ./ mv);
% figure(742); clf; imagesc(X);
% buildGLM.visualizeDesignMatrix(dm, 1); % optionally plot the first trial

%% Do some processing on the design matrix
dm = buildGLM.removeConstantCols(dm);
%% COULD BE VERY IMPORTANT LATER!!!
% colIndices = buildGLM.getDesignMatrixColIndices(dspec, 'LFP');
% dm = buildGLM.zscoreDesignMatrix(dm, [colIndices{:}]);

dm = buildGLM.addBiasColumn(dm); % DO NOT ADD THE BIAS TERM IF USING GLMFIT
wxa = nan(ncells,13,ncells);
wva = nan(ncells,13,ncells);
addpath(genpath('C:\Users\Loomis\Documents\Scripts\neuroGLM-master\matRegress'))
%% Get the spike trains back to regress against
for cell_num = 1 : ncells
ys{cell_num} = buildGLM.getBinnedSpikeTrain(expt, ['sp' num2str(cell_num)], dm.trialIndices);
end
parfor cell_num = 1 : ncells
[wx,wv] = glm_loop(dm,ys{cell_num},ncells,dspec)
wxa(:,:,cell_num) = wx;
wva(:,:,cell_num) = wv;
end
save(['glm_prelim_state' num2str(state) '.mat'],'wxa','wva','gu')
end
% %%
% fig = figure(2913); clf;
% nCovar = numel(dspec.covar);
% for kCov = 1:16
%     label = dspec.covar(kCov).label;
%     subplot(16, 1, kCov);
%     errorbar(ws.(label).tr, ws.(label).data, sqrt(wvar.(label).data));
%     title(label);
% end
% 
% return
% 
% %{
% %% Specify the model
%hasBias = true;
%model = buildGLM.buildModel(dspec, 'Poisson', 'exp', hasBias);
% 
% %% Do regression
% [w, stats] = fitGLM(model, dm, y);
% %}
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
