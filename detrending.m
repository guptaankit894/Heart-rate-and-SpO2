function [detrended_sig]=detrending(signal)
z=signal;
T=length(z);
lambda=10;
I=speye(T);
D2=spdiags(ones(T-2,1)*[1 -2 1],[0:2],T-2,T);
detrended_sig=(I-inv(I+lambda^2*D2'*D2))*z;
return