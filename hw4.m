%%Read Img, 0~1
img_reference = im2double(imread('frame_0038.png'));
img_39 = im2double(imread('frame_0039.png'));
img_40 = im2double(imread('frame_0040.png'));
img_41 = im2double(imread('frame_0041.png'));
img_42 = im2double(imread('frame_0042.png'));
img_43 = im2double(imread('frame_0043.png'));
%%Res img
% showResidualImg(img_reference,img_39,img_43,8,8,'FullSearch');
% showResidualImg(img_reference,img_39,img_43,16,8,'FullSearch');
% showResidualImg(img_reference,img_39,img_43,8,16,'FullSearch');
% showResidualImg(img_reference,img_39,img_43,16,16,'FullSearch');
% showResidualImg(img_reference,img_39,img_43,8,8,'logSearch');
% showResidualImg(img_reference,img_39,img_43,16,8,'logSearch');
% showResidualImg(img_reference,img_39,img_43,8,16,'logSearch');
% showResidualImg(img_reference,img_39,img_43,16,16,'logSearch');

%%SAD && PSNR
calculatePSNR(8,8,'FullSearch',img_reference,img_39,img_40,img_41,img_42,img_43);
calculatePSNR(16,8,'FullSearch',img_reference,img_39,img_40,img_41,img_42,img_43);
calculatePSNR(8,16,'FullSearch',img_reference,img_39,img_40,img_41,img_42,img_43);
calculatePSNR(16,16,'FullSearch',img_reference,img_39,img_40,img_41,img_42,img_43);
calculatePSNR(8,8,'LogSearch',img_reference,img_39,img_40,img_41,img_42,img_43);
calculatePSNR(16,8,'LogSearch',img_reference,img_39,img_40,img_41,img_42,img_43);
calculatePSNR(8,16,'LogSearch',img_reference,img_39,img_40,img_41,img_42,img_43);
calculatePSNR(16,16,'LogSearch',img_reference,img_39,img_40,img_41,img_42,img_43);



