clc
clear
%D:\下载\978-7-302-46774-8MATLAB智能算法代码\Intelligent algorithm\10\s10_4\Lenna.bmp'));%
close all
trees= imread('CLRIS012.jpg');%more quickly
%D:\yaoxl\大创2\图集\KPIS\KPIS001.bmp
% figure,
% subplot(211)
% imshow(img);
% img=myhisteq(img);
% subplot(212)
% imshow(img);

%img=t(:,:,1);
%imshow(img)
%img=histeq(img);
%img=double(img)+0.006*double(img) .*(255-double(img));
srgb2lab=makecform('srgb2lab');
lab2srgb=makecform('lab2srgb');
trees_lab=applycform(trees,srgb2lab);
max=100;
L=trees_lab(:,:,1)/max;
% 
% trees_imadjust=trees_lab;
% trees_lab(:,:,1)=imadjust(L)*max;
% trees_imadjust=applycform(trees_imadjust,lab2srgb);
% 
trees_histeq=trees_lab;
trees_histeq(:,:,1)=histeq(L)*max;
trees_histeq=applycform(trees_histeq,lab2srgb);
% 
% trees_adapthisteq=trees_lab;
% trees_adapthisteq(:,:,1)=adapthisteq(L)*max;
% trees_adapthisteq=applycform(trees_adapthisteq,lab2srgb);

img=rgb2gray(trees_histeq);
cluster_num = 2;%设置分类数
maxiter = 60;%最大迭代次数
%-------------随机初始化标签----------------
%label = randi([1,cluster_num],size(img));
%-----------kmeans最为初始化预分割----------
label = kmeans(img(:),cluster_num);
label = reshape(label,size(img));
iter = 0;
b=label;
while iter < maxiter
    %-------计算先验概率---------------
    %这里我采用的是像素点和3*3领域的标签相同
    %与否来作为计算概率
    %------收集上下左右斜等八个方向的标签--------
    label_u = imfilter(label,[0,1,0;0,0,0;0,0,0],'replicate');
    label_d = imfilter(label,[0,0,0;0,0,0;0,1,0],'replicate');
    label_l = imfilter(label,[0,0,0;1,0,0;0,0,0],'replicate');
    label_r = imfilter(label,[0,0,0;0,0,1;0,0,0],'replicate');
    label_ul = imfilter(label,[1,0,0;0,0,0;0,0,0],'replicate');
    label_ur = imfilter(label,[0,0,1;0,0,0;0,0,0],'replicate');
    label_dl = imfilter(label,[0,0,0;0,0,0;1,0,0],'replicate');
    label_dr = imfilter(label,[0,0,0;0,0,0;0,0,1],'replicate');
    p_c = zeros(cluster_num,size(label,1)*size(label,2));
    %计算像素点8领域标签相对于每一类的相同个数
    for i = 1:cluster_num
        label_i = i * ones(size(label));
        temp = ~(label_i - label_u) + ~(label_i - label_d) + ...
            ~(label_i - label_l) + ~(label_i - label_r) + ...
            ~(label_i - label_ul) + ~(label_i - label_ur) + ...
            ~(label_i - label_dl) +~(label_i - label_dr);
        p_c(i,:) = temp(:)/8;%计算概率
    end
    p_c(find(p_c == 0)) = 0.001;%防止出现0
    %---------------计算似然函数----------------
    mu = zeros(1,cluster_num);
    sigma = zeros(1,cluster_num);
    %求出每一类的的高斯参数--均值方差
    for i = 1:cluster_num
        index = find(label == i);%找到每一类的点
        data_c = double(img(index));
        mu(i) = mean(data_c);%均值
        sigma(i) = var(data_c);%方差
    end
    p_sc = zeros(cluster_num,size(label,1)*size(label,2));
%     for i = 1:size(img,1)*size(img,2)
%         for j = 1:cluster_num
%             p_sc(j,i) = 1/sqrt(2*pi*sigma(j))*...
%               exp(-(img(i)-mu(j))^2/2/sigma(j));
%         end
%     end
    %------计算每个像素点属于每一类的似然概率--------
    %------为了加速运算，将循环改为矩阵一起操作--------
    for j = 1:cluster_num
        MU = repmat(mu(j),size(img,1)*size(img,2),1);
        p_sc(j,:) = 1/sqrt(2*pi*sigma(j))*...
            exp(-(double(img(:))-MU).^2/2/sigma(j));
    end 
    %找到联合一起的最大概率最为标签，取对数防止值太小
    [~,label] = max(log(p_c) + log(p_sc));
    %改大小便于显示
    %label = reshape(label,size(img));
    %---------显示----------------
    %if ~mod(iter,6) 
    %    figure;
    %    n=1;
    %end
    %subplot(2,3,n);
    %imshow(label,[]);
    t=label;
%     title(['iter = ',num2str(iter)]);
%     pause(0.1);
%     n = n+1;
    iter = iter + 1;
end
m=numel(t);
x=length(find(t==1));
y=min(x,m-x);
%I=imread('D:\下载\978-7-302-46774-8MATLAB智能算法代码\Intelligent algorithm\10\s10_4\rice_noise.tif');
BW1=edge(t,'Roberts',0.04);    	%Roberts算子
BW2=edge(t,'Sobel',0.04);    	%Sobel算子
BW6=edge(b,'Sobel',0.04);    	%Sobel算子
BW3=edge(t,'Prewitt',0.04);        	%Prewitt算子
BW4=edge(t,'LOG',0.004);         	% LOG算子
BW5=edge(t,'Canny',0.04);         	% Canny算子
figure;
subplot(2,3,1),
imshow(t,[])
title('分割后图像')
subplot(2,3,2),
imshow(BW1)
title('Roberts ')
subplot(2,3,3),
imshow(BW2)
title(' Sobel ')
subplot(2,3,4),
imshow(BW3)
title(' Prewitt ')
subplot(2,3,5),
imshow(BW4)
title(' LOG ')
subplot(2,3,6),
imshow(BW5)
title('Canny ')
g1=length(find(BW1==1))/2;
g2=length(find(BW2==1))/2;
g3=length(find(BW3==1))/2;
g4=length(find(BW4==1))/2;
g5=length(find(BW5==1))/2;
g6=length(find(BW6==1))/2;
h1=y/g1
h2=y/g2
h3=y/g3
h4=y/g4
h5=y/g5
h6=y/g6