function [wx,wv] = glm_loop(dm,y,ncells,dspec)

%% Least squares for initialization
tic
wInit = dm.X \ y;
toc

%% Use matRegress for Poisson regression
% it requires `fminunc` from MATLAB's optimization toolbox
tic

fnlin = @nlfuns.exp; % inverse link function (a.k.a. nonlinearity)
lfunc = @(w)(glms.neglog.poisson(w, dm.X, y, fnlin)); % cost/loss function

opts = optimoptions(@fminunc, 'Algorithm', 'trust-region', ...
    'GradObj', 'on', 'Hessian','on');

[wml, nlogli, exitflag, ostruct, grad, hessian] = fminunc(lfunc, wInit, opts);
wvar = diag(inv(hessian));
disp('another one')
toc
%% Alternative maximum likelihood Poisson estimation using glmfit
% [w, dev, stats] = glmfit(dm.X, y, 'poisson', 'link', 'log');
% wvar = stats.se.^2;

%% Visualize
ws = buildGLM.combineWeights(dm, wml);
wvar = buildGLM.combineWeights(dm, wvar);
wx=[];
for k = 1 : ncells
wx(k,:) = ws.(dspec.covar(k).label).data;
wv(k,:) = wvar.(dspec.covar(k).label).data;
end
end