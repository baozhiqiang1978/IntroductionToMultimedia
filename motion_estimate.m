function [psnr, sumSAD,imgRC] =motion_estimate(img_test,img_ref,blockSize,searchLimit,mode)
%{
img_test=im2double(imread('frame_0038.bmp'));
img_ref=im2double(imread('frame_0038.bmp'));
blockSize=8;
searchLimit=8;
mode='FullSearch';
%}
%% parameter0
tic
M = floor(size(img_ref, 1)/blockSize)*blockSize;
N = floor(size(img_ref, 2)/blockSize)*blockSize;
img_ref  = img_ref(1:M, 1:N, :);
img_test = img_test(1:M, 1:N, :);
%% padding
img_ref  = padarray(img_ref,  [blockSize/2 ,blockSize/2], 'replicate');
img_test = padarray(img_test, [blockSize/2 ,blockSize/2], 'replicate');
img_ref  = padarray(img_ref,  [searchLimit, searchLimit]);
img_test = padarray(img_test, [searchLimit, searchLimit]);
%%
[M N C]     = size(img_ref);
L           = floor(blockSize/2);
blockRange  = -L:L-1;
xc_range    = searchLimit+2*L+1 : blockSize : M-(searchLimit);
yc_range    = searchLimit+2*L+1 : blockSize : N-(searchLimit);
imgRC=zeros(size(img_test,1),size(img_test,2),3);
Vx = zeros(length(xc_range),length(yc_range) );
Vy = zeros(length(xc_range),length(yc_range) );
sumSAD=0;
%%
for i = 1:length(xc_range)
    for j = 1:length(yc_range),
        xc = xc_range(i);
        yc = yc_range(j);
        
        block = img_test(xc + blockRange,yc + blockRange , :);
        
        % Choose either one of the followings
        if strcmp(mode,'FullSearch')==1,
        [Vx(i,j), Vy(i,j),blockmin,SADmin]= FullSearch(block, img_ref, xc, yc, searchLimit);
        imgRC(xc + blockRange,yc + blockRange,:)=blockmin;
        else %if logSearch
        [Vx(i,j), Vy(i,j),blockmin,SADmin]= logSearch(block, img_ref, xc, yc, searchLimit);
        imgRC(xc + blockRange,yc + blockRange,:)=blockmin;
        end
        sumSAD=sumSAD+SADmin;
    end
end
toc
c=blockSize/2+searchLimit;
imgRC=imgRC(c+1:size(imgRC,1)-c,c+1:size(imgRC,2)-c,:);
img_ref=img_ref(c+1:size(img_ref,1)-c,c+1:size(img_ref,2)-c,:);
psnr=clcPSNR(imgRC,img_ref)
end
