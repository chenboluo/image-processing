clc;
clear;
f_ori=imread('hc4.jpg');
f_ori=f_ori(:,:,1);%�Ҷ�ͼ��
cluster=2; %������
se=3; %��ʼ������ ��ϳ̶�
w_size=3; % ���ڴ�С
[center1,U1,~,t1]=FRFCM(double(f_ori),cluster,se,w_size);
f_seg=fcm_image(f_ori,U1,center1);
imshow(f_ori),title('Original image');
figure,imshow(f_seg);title('segmentated result');