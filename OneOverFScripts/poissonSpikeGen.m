function [ spikeMat , tVec ] = poissonSpikeGen (fs, fr , tSim , nTrials )
%firing rate, simulation time, number of neurons
dt = 1/fs; % s
nBins = floor ( tSim / dt ) ;
spikeMat = rand ( nTrials , nBins ) < fr * dt ;
tVec = 0: dt : tSim - dt ;
end