clear;clc;
img = imread("result.png");
sigma=50;
%img = (img + sigma*rand(size(img)));
%img = imnoise(img);
% figure;imshow(uint8(img));
[m,n,p] = size(img);
%output = zeros(m,n);
output(:,:,1) = NLmeansfilter(double(img(:,:,1)), 2, 5,7);
output(:,:,2) = NLmeansfilter(double(img(:,:,2)), 2, 5,7);
output(:,:,3) = NLmeansfilter(double(img(:,:,3)), 2, 5,7);

% search_size = 1;
% windows_size = 5;
% img = padarray(img, [windows_size, windows_size], 'replicate');
% kernel = fspecial('gaussian', [2 * search_size + 1, 2 * search_size + 1], 1);
% 
% for i = 1:m
%     for j = 1 :n
%         i1 = i + windows_size;
%         j1 = j + windows_size;
%         center = img(i1-search_size:i1+search_size,j1-search_size:j1+search_size);
%         ave = 0;
%         sweight = 0;
%         rmin = i1 - windows_size + search_size;
%         rmax = i1 + windows_size - search_size;
%         smin = j1 - windows_size + search_size;
%         smax = j1 + windows_size - search_size;        
%         for r = rmin : rmax
%             for s = smin:smax
%                if(i1==r&&j1==s)
%                    continue;
%                end
%                ob = img(r-search_size:r+search_size,s-search_size:s+search_size);
%                d = sum(sum(kernel.*((center-ob).^2)));
%                w = exp(-d/(10));
%                sweight = sweight + w;
%                ave = ave + w*img(r,s);
%             end
%         end
%         output(i,j) = ave/sweight;
%     end
% end
 figure;imshow(uint8(output));


