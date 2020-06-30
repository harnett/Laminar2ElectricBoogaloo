function [fra,meanfr,sig_fr] = FiringRate_Across_States(unitdata,states)

%% get unit data
%% get gs for states
%% get intersection, calc number of spikes divided by length of state
%% now, get dn, turn into fieltrip2mat_epochs (1s)
%% get firing rate each second
%% get ranksum for sig diff
%% get average FR across individual seconds
addpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))

for k = 1 : length(unitdata)
spk(k).time = unitdata(k).ts;
end

for s = 1 : 3
gs=time_STATE2gs(states(s).t);
[dn,~] = binspikes(spk,1000);

if length(dn) < max(gs)
dn = [dn; zeros(max(gs)-length(dn),size(dn,2))]; % pad dn with zeros just in case lfp exceeds spikes
end

dn(dn>=1)=1;
fra(s,:) = sum(dn(gs,:))./length(gs).*1000;

nUnit = size(dn,2);
[dn,t] = binspikes(spk,1);
tmp = intersect(round(t)+1,round(gs./1000)); tmp(tmp>=length(dn))=[];
sfr{s} = dn(tmp,:);
meanfr(s,:) = mean(tmp);
end

sig_fr = nan(3,3,nUnit);

for s = 1 : 3
    for ss = 1 : 3
        for un = 1 : nUnit
            [r] = ranksum(sfr{s}(:,un),sfr{ss}(:,un));
            sig_fr(s,ss,un) = r;
        end
    end
end
rmpath(genpath('C:\Users\Loomis\Documents\Packages\chronux_2_12'))
end