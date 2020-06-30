function pow = fdnorm(frq)
    pow = frq.powspctrm;
    if ndims(pow)==3
        pow = squeeze(nanmean(pow,1));
    end
    pow = pow ./ repmat(max(pow),[size(pow,1) 1]);
end