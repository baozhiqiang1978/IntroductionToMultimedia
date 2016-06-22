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
fileName = 'shaky_car.avi';
%fileName = 'die_another_day_small_grey.avi';
end
nFrames = []; %20;%[]; % num desired frames to process ([] gets all)
% read file
mov = VideoReader(fileName);
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
% do GC-BPM stabilization (gather statistics)
tic
[Ms,Va,Vg,V] = stabilizeMovie_GCBPM(M);
t = toc; fprintf('%.2f seconds per frame\n',t/(nFrames-1));
% assemble for playback of final movie
H2 = figure; set(H2,'name','generating final movie ...')
for i = 1:length([Ms(1,1,:)])
 imshow(Ms(:,:,i),[0 255]);
movStab(i) = getframe(H2);
end
close(H2)
H3 = figure; set(H3,'name','Final Stabilized Movie')
imshow(Ms(:,:,1),[0 255]);
curPos = get(H3,'position');
set(H3,'position',... % [left bottom width height]
 [60 scrz(4)-100-(movInfo.Height+50) curPos(3:4)]);
movie(H3,movStab,1,movInfo.FramesPerSecond)
% save out final movie & workspace
movie2avi(movStab,[fileName(1:end-4) '_out.avi'], ...
 'fps',movInfo.FramesPerSecond,'compression','None');
save(sprintf('Wkspace_at_d%d-%02d-%02d_t%02d-%02d-%02d',fix(clock)))
%profile report runtime
return

