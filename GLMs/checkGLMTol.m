function ic = checkGLMTol(x,y,distr)

distr = convertStringsToChars(distr);

[y,~] = internal.stats.getGLMBinomialData(distr,y);

x = [ones(size(x,1),1) x];
dataClass = superiorfloat(x,y);
x = cast(x,dataClass);
y = cast(y,dataClass);

% If x is rank deficient (perhaps because it is overparameterized), we will
% warn and remove columns, and the corresponding coefficients and std. errs.
% will be forced to zero.
[n,ncolx] = size(x);
[~,R,perm] = qr(x,0);
if isempty(R)
    rankx = 0;
else
    rankx = sum(abs(diag(R)) > abs(R(1))*max(n,ncolx)*eps(class(R)));
end
if rankx < ncolx
    ic = 1;
    perm = perm(1:rankx);
    x = x(:,perm);
else
    ic=0;
    perm = 1:ncolx;
end