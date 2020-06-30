function psc = psc_sim(fs,tlen,trise,tdecay)

%fs: sampling rate (should be ~100000)
%tlen: length of time in milliseconds
%trise, tdecay: rise/decay times in milliseconds

cf = fs./1000;
t = linspace(0,tlen,tlen.*cf);
trise = trise;
tdecay = tdecay;
psc = -exp(-t./trise) + exp(-t./tdecay);

psc = psc ./ sum(psc);

plot(t,psc)
end