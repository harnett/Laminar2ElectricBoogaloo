function cohs = Coh_Fieldtrip_States(lfp,states,seglen)
for s = 1 : 3
dat = contgs2seg(lfp,seglen,time_STATE2gs(states(s).t));
cohs{s} = Coh_Fieldtrip(dat,[],[0 100],[]);
end
end