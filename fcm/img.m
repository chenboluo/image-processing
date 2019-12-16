clear ; 
clc;
I = imread('tu.jpg');
%I = rgb2gray(I);
[m, n, p] = size(I);
X = reshape(double(I), m*n, p);
k = 2; b = 2;
[C, dist, J] = fcm(X, k, b,m,n);
[~, label] = min(dist, [], 2);
% C(2,1)=0;
figure
imshow(uint8(reshape(C(label,:), m, n, p)))
%figure
%plot(1:length(J), J, 'r-*'), xlabel('#iterations'), ylabel('objective function')
