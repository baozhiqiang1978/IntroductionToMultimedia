function showResidualImg(img_ref,img8,img17,blockSize,searchLimit,mode)
[PSNR1, SAD1,imgRC] = motion_estimate(img8, img_ref, blockSize,searchLimit,mode);
figure();
imshow(abs(imgRC-img8));
[PSNR1, SAD1,imgRC] = motion_estimate(img17, img_ref, blockSize,searchLimit,mode);
figure();
imshow(abs(imgRC-img17));

end