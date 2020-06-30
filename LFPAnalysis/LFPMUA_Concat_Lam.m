function lfpmua = LFPMUA_Concat_Lam(lfp,mua)
if strcmp(mua.label{1},lfp.label{1})
for k = 1 : length(mua.label)
mua.label{k} = ['m' mua.label{k}];
end
end
cfg=[]; lfpmua = ft_appenddata(cfg,lfp,mua);
end