function y = sfb(lo, hi, sf)

% y = sfb(lo, hi, sf)
%
% Synthesis filter bank
%
% lo - low frqeuency signal
% hi - high frequency signal
% sf - synthesis filters
% sf(:, 1) - lowpass filter (even length)
% sf(:, 2) - highpass filter (even length)
%
% y - output

N = 2*length(lo);
L = length(sf);
lo = upfirdn(lo, sf(:,1), 2, 1);
hi = upfirdn(hi, sf(:,2), 2, 1);
y = lo + hi;
y(1:L-2) = y(1:L-2) + y(N+[1:L-2]);
y = y(1:N);
y = cshift(y, 1-L/2);