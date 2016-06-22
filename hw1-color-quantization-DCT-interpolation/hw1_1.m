clc;
clear all;
close all;
img = imread('clash1.png');
%[imgQ,map]= rgb2ind(img,8,'nodither');
%imshow(imgQ,map);
imgVec=[reshape(img(:,:,1),[],1) reshape(img(:,:,2),[],1) reshape(img(:,:,3),[],1)];
imgVecCenter = [54.4604265315182,42.1025451316958,37.0031814146197;
    84.6089999570613,70.5372600798660,78.1668706256173;
    80.3121344222492,126.229435676710,195.942693963139;
    212.816621647431,170.490682382473,109.018853510136;
    178.386394827131,192.823489047242,211.188123515439;
    228.518085331409,229.685625054436,233.265226642113;
    143.931762510206,94.3801275321747,65.5584781678914;
    148.673459039177,124.089415167337,127.718852120347];
imgVecQ=pdist2(imgVec,imgVecCenter); %choosing the closest centroid to each pixel, 
[~,indMin]=min(imgVecQ,[],2);   %avoiding double for loop
imgVecNewQ=imgVecCenter(indMin,:);  %quantizing
imgVecQCount = imgVecNewQ(:,1);
testCount = hist(imgVecQCount, numel(unique(imgVecQCount)));
totalCount = histc(imgVecQCount, unique(imgVecQCount));
reshapeCount = reshape(totalCount,[1,8]);
total = sum(reshapeCount);
prob = reshapeCount/total
optNum = ceil(-log2(prob(prob>0))) 
H = sum(-(prob(prob>0).*(log2(prob(prob>0)))))
sortedPorb = sort(prob,'descend')

%imgNewQ=img;
%imgNewQ(:,:,1)=reshape(imgVecNewQ(:,1),size(img(:,:,1))); %arranging back into image
%imgNewQ(:,:,2)=reshape(imgVecNewQ(:,2),size(img(:,:,1)));
%imgNewQ(:,:,3)=reshape(imgVecNewQ(:,3),size(img(:,:,1)));
%figure,imshow(imgNewQ,[]);
ss = reshapeCount/total;
ss=sort(ss,'descend');  %the probabilities are sorted in descending order
siling=ceil(log2(1/ss(1))); %initial length is computed
sf=0; 
fano=0; 
%initializations for Pk
n=1;Hs=0; %initializations for entropy H(s)
for iii=1:length(ss)
   Hs=Hs+ ss(iii)*log2(1/ss(iii)); %solving for entropy
end
for o=1:length(ss)-1
   fano=fano+ss(o);
   sf=[sf 0]+[zeros(1,o) fano]; %solving for Pk for every codeword
   siling=[siling 0]+[zeros(1,o) ceil(log2(1/ss(o+1)))]; %solving for length every codeword
end
for r=1:length(sf)
    esf=sf(r); 
    for p=1:siling(r)    
        esf=mod(esf,1)*2;
        h(p)=esf-mod(esf,1); %converting Pk into a binary number       
    end
    hh(r)=h(1)*10^(siling(r)-1); %initializtion for making the binary a whole number
    for t=2:siling(r)
        hh(r)=hh(r)+h(t)*10^(siling(r)-t);    %making the binary a whole number
    end                                       %e.g. 0.1101 ==> 1101
end
tao=siling(1)*ss(1); %initialization for codeword length
for u=1:length(ss)-1 %computing for codeword length
   tao=tao+siling(u+1)*ss(u+1);
end
T=tao/n; %computing for average codeword length
B=[flipud(rot90(ss)),flipud(rot90(siling)),flipud(rot90(sf))];
disp([    ' prob     ',' encoding bits ','   product'])
disp(B)
disp(['Hs = ',num2str(Hs)])
disp(['T = ',num2str(T),' bits/symbol'])
disp([num2str(Hs),' <= ',num2str(T),' <= ',num2str(Hs+1)])