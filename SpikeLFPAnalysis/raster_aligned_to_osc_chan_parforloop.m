parfor i = 1 : 10
[avglfp,rast_singtrial,rast_avgmean,rast_avgstd] = raster_aligned_to_osc(unitdata,data,states(1),2,1000,i,[.5 3;9 16],5000)
avglfpsbi{i} = avglfp;
rast_avgmeansbi{i} = rast_avgmean;
rast_avgstdsbi{i} = rast_avgstd;
end