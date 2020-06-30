function pow = fdnormv2(pow)
    pow = pow ./ repmat(max(pow),[size(pow,1) 1]);
end