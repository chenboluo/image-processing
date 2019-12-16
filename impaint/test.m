clear;
clc;
tic
[i1,i2,i3,c,d,mov] = inpaint('content.png',[255 255 255]);
%[i1,i2,i3,c,d,mov] = inpaint('zoo.png','zoo1.png',[255 255 255]);
imshow(uint8(i1),[]);
toc