function diffs = xcorrTimestamps_Old(x, y)
diffs = [];
for i = 1:length(x)
    diffs = [diffs, y-x(i)];
end