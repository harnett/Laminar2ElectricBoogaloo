function gs=time_STATE2gs(time_STATE)

gs=[];
for k = 1 : length(time_STATE)
    gs = [gs time_STATE{k}];
end