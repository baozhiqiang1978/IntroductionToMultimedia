tic
MaxFrame=100;
filename = 'shaky_car.avi';%'Yuna Kim Skate America 2009 [fan cam].mp4' 
outputFile= 'shaky_car_L1.avi';
outVW = VideoWriter(outputFile);

hVideoSrc = vision.VideoFileReader(filename, 'ImageColorSpace', 'Intensity');
hVideoSrcColored = vision.VideoFileReader(filename);
videoInfo=info(hVideoSrc);
outVW.FrameRate = videoInfo.VideoFrameRate;
% Reset the video source to the beginning of the file.
reset(hVideoSrc);
reset(hVideoSrcColored);

hVPlayer = vision.VideoPlayer; % Create video viewer

% Process all frames in the video
movMean = step(hVideoSrc);
imgB = movMean;
imgBp = imgB;
correctedMean = imgBp;
ii = 2;
Hcumulative = eye(3);% 3x3 identity matrix 
imgDp2=imgB;%***

% Initial condition
%ini = zeros(1,4); 
ini{1} = imgB;
while ~isDone(hVideoSrc) && ii <= 4%limited number of frames
    disp(['ii=' num2str(ii)]);
    % Read in new frame
    imgA = imgB; % z^-1, previous frame
    imgAp = imgBp; % z^-1, previous transformed frame
    imgB = step(hVideoSrc); % read frame
    ini{ii} = imgB; % record first 4 frames
    movMean = movMean + imgB; 

    % Estimate transform from frame A to frame B
    Ft =StabilizationL1Robust(imgA,imgB);
    store_H{ii-1} = Ft;
    % cuz imgB [x y 1] almost= ([x y 1] in imgA )* Ft 
    Hcumulative = Ft * Hcumulative;
    
    Hinv=Hcumulative\eye(3);%inv(Hcumulative)
    Hinv(:,3) = [0 0 1].';
    imgBp = imwarp(imgB,affine2d(Hinv),'OutputView',imref2d(size(imgB)));
    % Display as color composite with last corrected frame
    step(hVPlayer, imfuse(imgAp,imgBp,'ColorChannels','red-cyan'));
    correctedMean = correctedMean + imgBp;
    
    imgBC = step(hVideoSrcColored);
    imgBpC = imwarp(imgBC,affine2d(Hinv),'OutputView',imref2d(size(imgB)));
    %writeVideo(outVW,imgBp);%write into output video
    ii = ii+1;
end

% initialize
imgA = ini{1};
imgB = ini{2};
imgC = ini{3};
imgD = ini{4};
imgDp = imgBp;

open(outVW);%open output file
while ~isDone(hVideoSrc) && ii < MaxFrame%limited number of frames
    % Read in new frame
    imgA = imgB; % z^-3, delay 3 duration
    imgB = imgC; % z^-2, delay 2 duration
    imgC = imgD; % z^-1, delay 1 duration
    imgCp = imgDp; % z^-1
    imgD = step(hVideoSrc);  % right now
       %%
    movMean = movMean + imgD;

    % Estimate transform from frame A to frame B
    %Ft =StabilizationL1Robust(imgA,imgB);
    store_H1 = store_H{1};
    store_H2 = store_H{2};
    Ft =StabilizationL1Robust_four(imgA,imgB,imgC,imgD, store_H1, store_H2);
    store_H{1} = store_H{2};
    store_H{2} = Ft;
    % cuz imgB [x y 1] almost= ([x y 1] in imgA )* Ft 
    Hcumulative = Ft * Hcumulative;
    Hinv=Hcumulative\eye(3);%inv(Hcumulative)
    Hinv(:,3) = [0 0 1].';
    imgDp = imwarp(imgD,affine2d(Hinv),'OutputView',imref2d(size(imgD)));
    %*** rectangular window
    imgAp2=imgDp2;
    imgDp2=imgDp;
    imgBp=imgDp;
    nonzero=~(imgBp==0);
    col=sum(nonzero,1);
    row=sum(nonzero,2);
    c1=find(col>=max(col)*0.8,1,'first');
    c2=find(col>=max(col)*0.8,1,'last');
    r1=find(row>=max(row)*0.8,1,'first');
    r2=find(row>=max(row)*0.8,1,'last');
    imgDp2(1:r1-1,:)=zeros(r1-1,size(imgBp,2));
    imgDp2(r2+1:end,:)=zeros(size(imgBp,1)-r2,size(imgBp,2));
    imgDp2(:,1:c1-1)=zeros(size(imgBp,1),c1-1);
    imgDp2(:,c2+1:end)=zeros(size(imgBp,1),size(imgBp,2)-c2);
    imgDp=imgDp2;
    imgCp=imgAp2;
    %***
    
    % Display as color composite with last corrected frame
    step(hVPlayer, imfuse(imgCp,imgDp,'ColorChannels','red-cyan'));
    correctedMean = correctedMean + imgDp;
    
    imgDC = step(hVideoSrcColored);
    imgDpC = imwarp(imgDC,affine2d(Hinv),'OutputView',imref2d(size(imgD)));
    %*** rectangular window for colored frame
    imgDpC(1:r1-1,:,:)=zeros(r1-1,size(imgDpC,2),3);
    imgDpC(r2+1:end,:,:)=zeros(size(imgDpC,1)-r2,size(imgDpC,2),3);
    imgDpC(:,1:c1-1,:)=zeros(size(imgDpC,1),c1-1,3);
    imgDpC(:,c2+1:end,:)=zeros(size(imgDpC,1),size(imgDpC,2)-c2,3);
    %***
    writeVideo(outVW,imgDp);%write into output video
    ii = ii+1;
end
close(outVW);%close output file
correctedMean = correctedMean/(ii-2);
movMean = movMean/(ii-2);

% Here you call the release method on the objects to close any open files
% and release memory.
release(hVideoSrc);
release(hVPlayer);

figure; imshowpair(movMean, correctedMean, 'montage');
title(['Raw input mean', repmat(' ',[1 50]), 'Corrected sequence mean']);
toc