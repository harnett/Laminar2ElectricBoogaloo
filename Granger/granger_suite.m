addpath(genpath('C:\Users\Loomis\Documents\Packages\gcpp'))
[bhat,LLK,aic] = granger_get_aic(unitdata,spind_gs);
[Phi,SGN,LLKR,ht] = granger_causality_comp(unitdata,time_STATE2gs(states(1).t),bhat,LLK,aic)
[Psi1,Psi2] = granger_sig(Phi,SGN,LLKR,ht)