function  [center, U, obj_U, iter_n]=FRFCM(data,cluster_n,diameter,w_size)
options = [2;   % ���־����ָ��
        100;    % ����������
        1e-5;   % ��С�ı��� 
        1];     % ��Ϣ��ʾ
expo = options(1);      
max_iter = options(2);     
obj_U = zeros(max_iter, 1); %Ŀ�꺯��
row=size(data, 1);col=size(data,2);
data_n = row*col;  % ͼ���С
data=data(:);
data_u=unique(data(:));%��ȡ����A �Ĳ�ͬԪ�ع��ɵ�������
n_r=size(data_u,1); % ��ͬ�Ҷ�ֵ
U=initfcm(cluster_n,n_r);   % ��������ʼֵ
sum_U{1}=double(U>0.5);sum_U{2}=sum_U{1};
% ����ֱ��ͼ
N_p=zeros(length(data_u),1);
   for i=1:length(data_u)
       N_p(i)=sum(data==data_u(i)); 
   end
 Num=ones(cluster_n,1)*N_p';
dist=zeros(cluster_n,n_r);dist2=zeros(cluster_n,data_n);
for w= 1:max_iter
    mf = Num.*(U.^expo); 
    center = mf*data_u./((ones(size(data, 2), 1)*sum(mf'))');
   for k=1: size(center, 1) 
     dist(k, :)=abs(center(k)-data_u)';
   end
   tmp=dist.^2;
   h1=(tmp+eps).^(-1/(expo-1));
   U=(h1)./(ones(cluster_n,1)*(sum(h1))+eps); 
if w>2
    sum_U{w}=double(U>0.5);
    obj_U(w)=sum(sum(abs(sum_U{w}-sum_U{w-1})));
    if obj_U(w)==0,break; end
end
end
iter_n = w; 
   for k2=1: size(center, 1) 
     dist2(k2, :)=abs(center(k2)-data)';
   end
   tmp =dist2+eps;
   h1=(tmp).^(-1/(expo-1));
   U=(h1)./(ones(cluster_n,1)*(sum(h1))+eps);  
   for k3=1: size(center, 1) 
      U1= U (k3,:);      
      U1=reshape(U1,[row,col]); 
      UU=medfilt2(U1,[w_size,w_size]); 
      GG(k3,:)=UU(:);
  end
   U=GG./(ones(cluster_n,1)*(sum(GG))+eps);  % ��׼��
   
   