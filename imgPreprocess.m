function img = imgPreprocess(name)
Nametemp = strcat(name,'.png');
img =  imread(Nametemp);
Bmptemp = strcat(name,'.bmp');
imwrite(img,Bmptemp);
img = im2double(img);