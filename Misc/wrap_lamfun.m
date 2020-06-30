function wrap_lamfun(sess,fn,fout)

for k = 1 : length(sess)
    cd(sess{k})
    eval(fn)
    eval(fout)
end

end