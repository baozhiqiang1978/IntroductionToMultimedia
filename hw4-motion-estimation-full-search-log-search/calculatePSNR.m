function calculatePSNR(blockSize,searchLimit,mode,img_ref,img_39,img_40,img_41,img_42,img_43)
[PSNR1, SAD1,imgRC] = motion_estimate(img_39, img_ref, blockSize,searchLimit,mode);
[PSNR2, SAD2,imgRC]  = motion_estimate(img_40, img_ref, blockSize,searchLimit,mode);
[PSNR3 ,SAD3,imgRC] = motion_estimate(img_41, img_ref,blockSize,searchLimit,mode);
[PSNR4 ,SAD4,imgRC]  = motion_estimate(img_42, img_ref, blockSize,searchLimit,mode);
[PSNR5 ,SAD5,imgRC]  = motion_estimate(img_43, img_ref, blockSize,searchLimit,mode);
PSNR = [PSNR1,PSNR2,PSNR3,PSNR4,PSNR5];
SAD = [SAD1,SAD2,SAD3,SAD4,SAD5];

figure();
title('PSNR')
x=39:43;
plot(x,PSNR);

figure()
title('SAD value')
x=39:43;
plot(x,SAD);
end
