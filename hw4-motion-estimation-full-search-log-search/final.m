%A. A listing of the main test routine ¡§imageStabilizeMain.m¡¨ follows.
% filename: imageStabilizeMain.m
% author: Alan Brooks
% description: dunno yet
% version history:
% 06-Mar-2003 created
% 08-Mar-2003 image I/O added
% 09-Mar-2003 v0_1 archived
% 10-Mar-2003 v0_2, v0_3 archived
function [] = imageStabilizeMain(fileName)
%profile on
% setup vars
if ~exist('fileName','var')
%fileName = 'flag.avi';
%fileName = 'temple.avi';
%fileName = 'elevator.avi';
%fileName = 'smoke_building.avi';
%fileName = 'cars_and_zoom.avi';
%fileName = 'shaky_math.avi';
%fileName = 'twist_couch.avi';
%fileName = 'building2_small_25fps.avi';
%fileName = 'Light_jitter_qt.avi';
fileName = 'test.avi';
%fileName = 'die_another_day_small_grey.avi';
end
ffmpeg -i test.avi test.mp4
nFrames = []; %20;%[]; % num desired frames to process ([] gets all)
% read file
mov = aviread(fileName);
movInfo = aviinfo(fileName);
nFrames = min([movInfo.NumFrames nFrames]);
% setup figure
H1 = figure; set(H1,'name','Original Movie')
scrz = get(0,'ScreenSize');
set(H1,'position',... % [left bottom width height]
 [60 scrz(4)-100-(movInfo.Height+50) ...
 movInfo.Width+50 movInfo.Height+50]);
% play orig movie
movie(H1,mov,1,movInfo.FramesPerSecond,[25 25 0 0])
close(H1)
% convert from indexed image seq to grayscale double [0,255] ... make uint8 ??
M = uint8(zeros(movInfo.Height,movInfo.Width,nFrames));
for i = 1:nFrames
 M(:,:,i) = uint8(floor(256*ind2gray(mov(i).cdata,mov(i).colormap)));
end
%figure,imshow(M(:,:,i),[0 255]); % show last frame