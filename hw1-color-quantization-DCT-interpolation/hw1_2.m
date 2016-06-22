clc;
clear all;
close all;
%read in the image
img = imread('clash2.png'); 
img = im2double(img);
blocksize = 8;
index_i = 0;
index_j = 0;
mask_2 = [1   1   0   0   0   0   0   0
        1   1   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0];
mask_4 = [1   1   1   1   0   0   0   0
        1   1   1   1   0   0   0   0
        1   1   1   1   0   0   0   0
        1   1   1   1   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0];

matrix = img([index_i*8+1: (index_i+1)*8],[index_j*8+1: (index_j+1)*8]);
%filtered_matrix = double(matrix).*mask;
%temp = zeros([8,8]);
%for m = 1:blocksize-1
%    for n = 1:blocksize-1
%         temp(1,1) = 1/blocksize * matrix(1,1)* cos(pi*(2*m+1)* 1/(2*blocksize))* cos(pi*(2*n+1)* 1/(2*blocksize))  
%    end
%end
%for j = 0: blocksize - 1
%  DCT_trans(i + 1, j + 1) = sqrt(1 / blocksize) * cos ((2 * j + 1) * i * pi / (2 * blocksize));
%end
%i = 0;
%for j = 0: blocksize - 1
%  DCT_trans(i + 1, j + 1) = sqrt(1 / blocksize);
%end
 
for i = 0: blocksize - 1
  for j = 0: blocksize - 1
    if i == 0
        DCT_trans(i+1,j+1) = sqrt(1/blocksize);
        %disp(i);
    else
        DCT_trans(i+1, j+1) = sqrt(2 / blocksize)* cos ((2 * j + 1) * i * pi / (2 * blocksize));
        %disp(j)
    end
  end
end
[rows,cols]= size(img);
rows = rows/8;
cols = cols/8;
for i = 0: cols-1
    for j = 0: rows-1
        DCT_matrix = img([i*8+1: (i+1)*8],[j*8+1: (j+1)*8]);
        temp = (DCT_trans)*(DCT_matrix)*(DCT_trans'); 
        temp = temp.* mask_4;
        output([i*8+1: (i+1)*8],[j*8+1: (j+1)*8]) = temp;
    end
end
%now output for the transformed pic
for i = 0: cols-1
    for j = 0: rows-1
        inverseDCT_matrix = output([i*8+1: (i+1)*8],[j*8+1: (j+1)*8]);
        temp = (DCT_trans')*(inverseDCT_matrix)*(DCT_trans);
        temp = (temp);
        reconstruct_output([i*8+1: (i+1)*8],[j*8+1: (j+1)*8]) = temp;
    end
end

mse=0;
mse=mse+sum(sum((img-reconstruct_output).^2)));
mse=mse/(rows*cols*64);
psnrx=20*log10(1)-10*log10(mse);
%
PSNR = 0;
%mse = 0;
for i = 1:rows
  for j = 1:cols
     mse = mse + (img(i, j) - reconstruct_output(i, j)) ^ 2;
  end
end
mse_or = mse;
max_value = max(reconstruct_output)
max_value = max(max_value)
mse = (mse)/(rows^2*64);
PSNR = 10*log10((1^2)/(mse));
%output = uint16(output)
%reconstruct_output= uint8(reconstruct_output);
function_psnr = psnr(img, reconstruct_output,1)
figure, imshow(output)
%figure, imshow(reconstruct_output)
figure, imshow(reconstruct_output,[])