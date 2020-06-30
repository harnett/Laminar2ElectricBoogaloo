
% xcorr2lag:  Cross correlation for two dimensional vectors, performed with specified lags
%
% [xc2l,lagsY,lagsX] = xcorr2lag(arrayA, [arrayB,] lags)
%
% --INPUTS--
% arrayA    - M x N input array of data
% arrayB    - M x N input array of data (optional: if ommitted, auto-cross-correlation will be performed)
% lags      - 1 x 2 input array specifying the first and second dimension lags
%
% --OUTPUTS--
% xc2l      - The cross-correlation output array [size = 2*lags(1)+1 X 2*lags(2)+1]
% lagsY     - The 2-D array of lags in the first dimension
% lagsX     - The 2-D array of lags in the second dimension
%
%
% Author: Spencer Torene <spencertorene@gmail.com>
%
% Last Modified: 2015-09-30
% 
function [xc2l,lagsY,lagsX] = xcorr2lag(varargin)
    % Initialize in case of future errors forcing an early function exit
    xc2l = [];
    lagsY= [];
    lagsX= [];
    
    % Simple checks to see if the inputs are as specified
    if length(varargin) == 2
        lags = varargin{2};
        if length(lags) == 1
            lags = lags * ones(1,2);
        elseif length(lags) > 2
            fprintf('ERROR: The lag vector cannot be longer than 2.\n');
            return;
        end
        
        arrA = zeroPaddedArray(varargin{1},lags);
        arrB = arrA;
    elseif length(varargin) == 3
        lags = varargin{3};
        if length(lags) == 1
            lags = lags * ones(1,2);
        elseif length(lags) > 2
            fprintf('ERROR: The lag vector cannot be longer than 2.\n');
            return;
        end
        
        arrA = zeroPaddedArray(varargin{1},lags);
        arrB = zeroPaddedArray(varargin{2},lags);
    else
        fprintf('ERROR: You must specify one or two input arrays, and a lag vector of length 2.\n');
        return;
    end
    
    % Better initialization, now that we know what we're dealing with
    xc2l = zeros(2*lags(1)+1,2*lags(2)+1);
    [lagsY,lagsX] = meshgrid(-lags(1):lags(1), -lags(2):lags(2));
    
    % The actual meat of the cross-correlation
    for iLag1 = -lags(1):lags(1)
        for iLag2 = -lags(2):lags(2)
            xc2l(iLag1+lags(1)+1,iLag2+lags(2)+1) = sum(sum(arrA .* circshift(arrB,[iLag1 iLag2])));
        end
    end    
end
% Helper function to give us zero-padded arrays large enough to do the cross-correlations
function ZPA = zeroPaddedArray(input,lags)
    ZPA = cat(1, input, zeros(    lags(1), size(input,2)));
    ZPA = cat(2,   ZPA, zeros(size(ZPA,1),        lags(2)));
end   