function psnr=clcPSNR(imgRC,img_ref)
m=size(imgRC,1);
l=size(imgRC,2);
mse=0;
 for k=1:3
    for i=1:m
         for j=1:l
           mse=mse+((imgRC(i,j,k)-img_ref(i,j,k))^2);
         end
    end
 end
 mse=mse/(m*l*3);
 psnr=20*log10(1)-10*log10(mse);
end