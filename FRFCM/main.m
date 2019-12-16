clc;
clear;
f_ori=imread('hc4.jpg');
f_ori=f_ori(:,:,1);%灰度图像
cluster=2; %中心数
se=3; %初始化参数 混合程度
w_size=3; % 窗口大小
[center1,U1,~,t1]=FRFCM(double(f_ori),cluster,se,w_size);
f_seg=fcm_image(f_ori,U1,center1);
imshow(f_ori),title('Original image');
figure,imshow(f_seg);title('segmentated result');