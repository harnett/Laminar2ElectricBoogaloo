function [xc, xcNoShuffle, shufflexc] = xcorrShuffleSub(r1, r2, lags)

    N = size(r1,1);

    xcNoShuffle = zeros(1, 2*lags+1);

    for i = 1 : N

        xcNoShuffle = xcNoShuffle + (xcorr(r1(i, :), r2(i, :), lags, 'unbiased'));
        
        disp(i)
        

    end

    xcNoShuffle = xcNoShuffle / N; %adds the no shuffled together and means them

    shufflexc = xcorr(mean(r1,1), mean(r2,1), lags, 'unbiased');

    xc = xcNoShuffle - shufflexc;

    

end