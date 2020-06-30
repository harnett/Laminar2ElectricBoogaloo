function [Ftmp,tr] = spike_spind_grangercausality(unitdata,fs,st)
%tlen is epoch length in samples
%toilim is in samples at preferred resolution
addpath(genpath('C:\Users\Loomis\Documents\Packages\mvgc_v1.0'))
for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end

X = binspikes(spk,fs);

% temp reduce data

%X = X(1:(20*60*1000),:);

% smooth spike train

w = gausswin(19,5); %fwhm of ~5 in time domain

X = filter(w,1,X);
Xa=[];
for k = 1 : size(st,1)
    Xa = cat(3,Xa,permute(cont_to_segment(X(st(k,1):st(k,2),:),250),[2 1 3]));
end

Xa =zscore(Xa,[],2);

tr = zeros(1,length(Xa));

clear spk unitdata

%take in spike train

%

regmode   = 'OLS';  % VAR model estimation regression mode ('OLS', 'LWR' or empty for default)
icregmode = 'LWR';  % information criteria regression mode ('OLS', 'LWR' or empty for default)

morder    = 'AIC';  % model order to use ('actual', 'AIC', 'BIC' or supplied numerical value)
momax     = 20;     % maximum model order for model order estimation

acmaxlags = 1000;   % maximum autocovariance lags (empty for automatic calculation)

tstat     = '';     % statistical test for MVGC:  'F' for Granger's F-test (default) or 'chi2' for Geweke's chi2 test
alpha     = 0.05;   % significance level for significance test
mhtc      = 'FDR';  % multiple hypothesis test correction (see routine 'significance')

fres      = [];     % frequency resolution (empty for automatic calculation)

seed      = 0;      % random seed (0 for unseeded)

%% Model order estimation (<mvgc_schema.html#3 |A2|>)

% Calculate information criteria up to specified maximum model order.
% 
%ptic('\n*** tsdata_to_infocrit\n');
%[AIC,BIC,moAIC,moBIC] = tsdata_to_infocrit(Xa,momax,icregmode);
%ptoc('*** tsdata_to_infocrit took ');

% % Plot information criteria.
% 
% figure(1); clf;
% plot_tsdata([AIC BIC]',{'AIC','BIC'},1/fs);
% title('Model order estimation');
% 
% fprintf('\nbest model order (AIC) = %d\n',moAIC);
% fprintf('best model order (BIC) = %d\n',moBIC);
% 
% % Select model order.
% 
% if strcmpi(morder,'AIC')
%     morder = moAIC;
%     fprintf('\nusing AIC best model order = %d\n',morder);
% elseif strcmpi(morder,'BIC')
%     morder = moBIC;
%     fprintf('\nusing BIC best model order = %d\n',morder);
% else
%     fprintf('\nusing specified model order = %d\n',morder);
% end

morder = 11;

%% VAR model estimation (<mvgc_schema.html#3 |A2|>)

%F = zeros(size(X,2),size(X,2),length(Xa));

%for k = 1 : length(Xa)

% Estimate VAR model of selected order from data.

ptic('\n*** tsdata_to_var... ');
[A,SIG] = tsdata_to_var(Xa,morder,regmode);
ptoc;

% Check for failed regression

assert(~isbad(A),'VAR estimation failed');

% NOTE: at this point we have a model and are finished with the data! - all
% subsequent calculations work from the estimated VAR parameters A and SIG.

%% Autocovariance calculation (<mvgc_schema.html#3 |A5|>)

% The autocovariance sequence drives many Granger causality calculations (see
% next section). Now we calculate the autocovariance sequence G according to the
% VAR model, to as many lags as it takes to decay to below the numerical
% tolerance level, or to acmaxlags lags if specified (i.e. non-empty).

ptic('*** var_to_autocov... ');
[G,info] = var_to_autocov(A,SIG,acmaxlags);
ptoc;

% The above routine does a LOT of error checking and issues useful diagnostics.
% If there are problems with your data (e.g. non-stationarity, colinearity,
% etc.) there's a good chance it'll show up at this point - and the diagnostics
% may supply useful information as to what went wrong. It is thus essential to
% report and check for errors here.
% if  info.error
%     tr(k) = 1;
%     continue
% end

%% Granger causality calculation: time domain  (<mvgc_schema.html#3 |A13|>)

% Calculate time-domain pairwise-conditional causalities - this just requires
% the autocovariance sequence.

ptic('*** autocov_to_pwcgc... ');
Ftmp = autocov_to_pwcgc(G);
ptoc;

F(:,:,k) = Ftmp;

%end

end