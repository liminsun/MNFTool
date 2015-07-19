function [S,IM]=lbBssMSF(X)
%%blind separate signal -- maximum signal fraction 
%%the other name: maximun noise fraction (MNF)
%%the second order
%%X-- mixed signal S -- source signal IM--separation matrix
%%X (k x n) : k -- the number of channels ; n -- the number of samples
%%S (k x n) : k -- the number of components ; n -- the number of samples
%%IM (k x k)
%%Author: Limin Sun
%%Date  : 15.02.07

dX(:,1:size(X,2)-1) = X(:,1:size(X,2)-1)-X(:,2:size(X,2));
%1. take the eigenvector expansion of the covariance of dX
T = size(dX,2);
dX	= dX - mean(dX')' * ones(1,T);

[V,D] = eig((dX*dX')/T)	; 
% [V1,D1,V11] = svd((dX*dX')/T)	; 

% [puiss,k]	= sort(diag(D))	;
% 
scales		= sqrt(diag(D))	; % scales 
W  		= diag(1./scales)  * V'	;	% whitener

%2.whiten the original data WX
WX		= W*X;  
%3.compute the eigenvector expansion of the covariance of WX
T = size(X,2);
[U,D2] = eig((WX*WX')/T)	; 
% [U,D2,V2] = svd((WX*WX')/T)	; 

%4.define IM
IM = U'*W;
%5.compute the maximum noise fraction basis vectors
S = IM*X;
%%test result
return;