clear;
clc;
X = rand(200,2)*5;
B = rand(200,2)+6;
X = [X;B];
col_sum = sum(X);
%X = X./col_sum(ones(4,1),:);
[C,dist,J] = fcm(X,2,2);


figure(1)
subplot(2,1,1);
plot(X(:,1),'-b');
title('隶属数据值');
ylabel('第一类');
subplot(2,1,2);
plot(X(:,2),'-r');
ylabel('第二类');
xlabel('样本数');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2)
title('聚类图像');
plot(X(:,1),X(:,2),'*r');
maxu = max(dist,[],2);
index1 = find(dist(:,1)==maxu);
index2 = find(dist(:,2)==maxu);
plot(X(index1,1),X(index1,2),'*g');
%plot(X(3,index3),X(2,index3),'*g');
hold on
plot(X(index2,1),X(index2,2),'*r');
plot(C(1,1),C(1,2),'oy','Markersize',5,'linewidth',3);
plot(C(2,1),C(2,2),'ob','Markersize',5,'linewidth',3);
hold off;








