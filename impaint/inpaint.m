function [inpaintedImg,origImg,fillImg,C,D,fillMovie] = inpaint(imgFilename,fillColor)
%INPAINT  Exemplar-based inpainting.
%
% Usage:   [inpaintedImg,origImg,fillImg,C,D,fillMovie] ...
%                = inpaint(imgFilename,fillFilename,fillColor)
% Inputs: 
%   imgFilename    Filename of the original image.
%   fillColor      1x3 RGB vector specifying the color used to specify
%                  the fill region.
% Outputs:
%   inpaintedImg   The inpainted image; an MxNx3 matrix of doubles. 
%   origImg        The original image; an MxNx3 matrix of doubles.
%   fillImg        The fill region image; an MxNx3 matrix of doubles.
%   C              MxN matrix of confidence values accumulated over all iterations.
%   D              MxN matrix of data term values accumulated over all iterations.
%   fillMovie      A Matlab movie struct depicting the fill region over time. 
%
% Example:
%   [i1,i2,i3,c,d,mov] = inpaint('bungee0.png','bungee1.png',[0 255 0]);
%   plotall;           % quick and dirty plotting script
%   close; movie(mov); % grab some popcorn 
%
%   author: Sooraj Bhat

warning off MATLAB:divideByZero
[img,fillImg,fillRegion] = loadimgs(imgFilename,fillColor);
img = double(img);
origImg = img;
ind = img2ind(img);
sz = [size(img,1) size(img,2)];
sourceRegion = ~fillRegion;

% Initialize sophote values
[Ix(:,:,3) Iy(:,:,3)] = gradient(img(:,:,3));
[Ix(:,:,2) Iy(:,:,2)] = gradient(img(:,:,2));
[Ix(:,:,1) Iy(:,:,1)] = gradient(img(:,:,1));
Ix = sum(Ix,3)/(3*255); Iy = sum(Iy,3)/(3*255);
temp = Ix; Ix = -Iy; Iy = temp;  % Rotate gradient 90 degrees

% Initialize confidence and data terms
C = double(sourceRegion);
D = repmat(-.1,sz);

% Visualization stuff
if nargout==6
  fillMovie(1).cdata=uint8(img); 
  fillMovie(1).colormap=[];
  origImg(1,1,:) = fillColor;
  iter = 2;
end

iter=1;
% Seed 'rand' for reproducible results (good for testing)
% state 0 ָ�����Ժ����������������һ�����в�������ͬ
rand('state',0);

% Loop until entire fill region has been covered
while any(fillRegion(:))
  % any(A) ���A������Ԫ��Ϊ0���򷵻�False�����A�д��ڷ�0Ԫ�أ��򷵻�True
  % Find contour & normalized gradients of fill region
  dR = find(conv2(double(fillRegion),[1,1,1;1,-8,1;1,1,1],'same')>0);

  [Nx,Ny] = gradient(double(~fillRegion));
  N = [Nx(dR(:)) Ny(dR(:))];
  N = normr(N);  
  N(~isfinite(N))=0; % handle NaN and Inf
  
  % Compute confidences along the fill front
  for k=dR'
    Hp = getpatch(sz,k);
    q = Hp(~(fillRegion(Hp)));
    C(k) = sum(C(q))/numel(Hp);
  end
  
  % Compute patch priorities = confidence term * data term
  D(dR) = abs(Ix(dR).*N(:,1)+Iy(dR).*N(:,2)) + 0.001;
  priorities = C(dR).* D(dR);
  
  % Find patch with maximum priority, Hp
  [unused,ndx] = max(priorities(:));
  p = dR(ndx(1));
  [Hp,rows,cols] = getpatch(sz,p);
  toFill = fillRegion(Hp);
  
  % Find exemplar that minimizes error, Hq
  Hq = bestexemplar(img,img(rows,cols,:),toFill',sourceRegion);
  
  % Update fill region
  fillRegion(Hp(toFill)) = false;
  
  % Propagate confidence & isophote values
  C(Hp(toFill))  = C(p);
  Ix(Hp(toFill)) = Ix(Hq(toFill));
  Iy(Hp(toFill)) = Iy(Hq(toFill));
  
  % Copy image data from Hq to Hp
  ind(Hp(toFill)) = ind(Hq(toFill));
  img(rows,cols,:) = ind2img(ind(rows,cols),origImg);  

  % Visualization stuff
  if nargout==6
    ind2 = ind;
    ind2(fillRegion) = 1;
    fillMovie(iter).cdata=uint8(ind2img(ind2,origImg)); 
    fillMovie(iter).colormap=[];
  end
  iter = iter+1;
end

inpaintedImg=img;


%---------------------------------------------------------------------
% Scans over the entire image (with a sliding window)
% for the exemplar with the lowest error. Calls a MEX function.
%---------------------------------------------------------------------
function Hq = bestexemplar(img,Ip,toFill,sourceRegion)
m=size(Ip,1); mm=size(img,1); n=size(Ip,2); nn=size(img,2);
best = bestexemplarhelper(mm,nn,m,n,img,Ip,toFill,sourceRegion);
Hq = sub2ndx(best(1):best(2),(best(3):best(4))',mm);


%---------------------------------------------------------------------
% ����������Ϊ���ĵ�9x9������������
%---------------------------------------------------------------------
function [Hp,rows,cols] = getpatch(sz,p)
% [x,y] = ind2sub(sz,p);  % 2*w+1 == the patch size
w=4; p=p-1; 
% ����x��y�����к���
y=floor(p/sz(1))+1; p=rem(p,sz(1)); x=floor(p)+1;
rows = max(x-w,1):min(x+w,sz(1));
cols = (max(y-w,1):min(y+w,sz(2)))';
Hp = sub2ndx(rows,cols,sz(1));


%---------------------------------------------------------------------
% Converts the (rows,cols) subscript-style indices to Matlab index-style
% indices.  Unforunately, 'sub2ind' cannot be used for this.
%---------------------------------------------------------------------
function N = sub2ndx(rows,cols,nTotalRows)
X = rows(ones(length(cols),1),:);
Y = cols(:,ones(1,length(rows)));
N = X+(Y-1)*nTotalRows;


%---------------------------------------------------------------------
% ������ͼ��ת��ΪRGBͼ��,ʹ�á�img����Ϊ��ɫӳ��
%---------------------------------------------------------------------
function img2 = ind2img(ind,img)
for i=3:-1:1, temp=img(:,:,i); img2(:,:,i)=temp(ind); end;


%---------------------------------------------------------------------
% ��RGBͼ��������ͼ�� 
%---------------------------------------------------------------------
function ind = img2ind(img)
s=size(img); ind=reshape(1:s(1)*s(2),s(1),s(2));


%---------------------------------------------------------------------
%ȷ���������
%---------------------------------------------------------------------
function [img,fillImg,fillRegion] = loadimgs(imgFilename,fillColor)
%imgFilename �޿ն���ͼ��
%fillFilename �пն���ͼ��
%fillColor �ն���ɫ
%fillRegion ��fillImg�еĿն������߼��ж�
img = imread(imgFilename); fillImg = img;
fillRegion = fillImg(:,:,1)>=fillColor(1)-2 & fillImg(:,:,2)>=fillColor(2)-2 & fillImg(:,:,3)>=fillColor(3)-2;