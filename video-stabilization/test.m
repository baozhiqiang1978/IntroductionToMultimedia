MaxFrame=100;
filename = 'shaky_car.avi';%'Yuna Kim Skate America 2009 [fan cam].mp4' 
outputFile= 'shaky_car_L1.avi';
outVW = VideoWriter(outputFile);
hVideoSrc = vision.VideoFileReader(filename, 'ImageColorSpace', 'Intensity');
%hVideoSrc = -hVideoSrc;
figure, img  =  step(hVideoSrc)