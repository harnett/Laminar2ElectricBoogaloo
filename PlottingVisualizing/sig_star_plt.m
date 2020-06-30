function sig_star_plt(x)
if x < .05 && x>.01 
    scatter(15,.02,30,'*')
elseif x<.01 && x>.001
    scatter([15 17],[.02 .02],30,'*')
elseif x < .001
    scatter([15 17 19],[.02 .02 .02],30,'k','*')
end