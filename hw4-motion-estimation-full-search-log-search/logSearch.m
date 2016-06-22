function [vx , vy,blockmin,min_SAD]=logSearch(block,img_ref,xc,yc,searchLimit)
%% parameter
blockSize= size(block,1);
blockRange = -floor(blockSize/2):floor(blockSize/2)-1;
searchRange=2^(log2(searchLimit)-1);
min_SAD = 1e5;
seaechDirection=[0,0 ; 1,0 ; 0,1 ; -1,0 ; 0,-1];
xt=xc;
yt=yc;
[height, width, channel] = size(img_ref);
%% search
while searchRange~=1,
    for i=1:5,
        x=xt+searchRange*seaechDirection(i,1);
        y=yt+searchRange*seaechDirection(i,2);
%         temp_x = min(x+blockRange)
%         temp_y = min(y+blockRange)
        %boundary check
        if(min(x+blockRange)>0 && max(x+blockRange) < height && min(y+blockRange)>0 && max(y+blockRange) < width)
        block_ref=img_ref(x+blockRange,y+blockRange,:);
		end
        SAD=sum(abs(block(:)-block_ref(:)));
        if SAD < min_SAD
            blockmin=block_ref;
            min_SAD=SAD;
            min_x=x;
            min_y=y;
        end
    end
    if xt-min_x==0 && yt-min_y==0,
        searchRange=ceil(searchRange/2);
    end
    xt=min_x;
    yt=min_y;
    
end
for i=-1:1
    for j=-1:1
        x=xt+i;
        y=yt+j;
        block_ref=img_ref(x+blockRange,y+blockRange,:);
        SAD=sum(abs(block(:)-block_ref(:)));
        if SAD < min_SAD
            blockmin=block_ref;
            min_SAD=SAD;
            min_x=x;
            min_y=y;
        end
    end
end
 vx = xc - min_x;
 vy = yc - min_y;
 
end