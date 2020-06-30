for k = 1 : 23
subplot(6,4,k)
x=squeeze(a(k,1,:));
h1=histogram(x(8:32)); hold on;
h2=histogram(x([1:7 33:end]));
xlim([-pi pi]), title(circ_wwtest(x(8:32),x([1:7 33:end]))), xlabel(circ_mean(x(8:32,:))-circ_mean(x([1:7 33:end])));
h1.Normalization = 'probability';
h1.BinWidth = 0.25;
h2.Normalization = 'probability';
h2.BinWidth = 0.25;
end