function [vx , vy,blockmin,min_SAD]=FullSearch(block,img_ref,xc,yc,searchLimit)
%% parameter
blockSize= size(block,1);
blockRange = -floor(blockSize/2):floor(blockSize/2)-1;
searchRange = searchLimit;
min_SAD = 1e5;
%% search
for i=-searchRange:searchRange
    for j=-searchRange:searchRange
        x=xc+i;
        y=yc+j;
        block_ref=img_ref(x+blockRange,y+blockRange,:);
        SAD=sum(abs(block(:)-block_ref(:)));
        if SAD < min_SAD
            blockmin=block_ref;
            min_SAD=SAD;
            min_x=x;
            min_y=y;
        end
         vx = xc - min_x;
         vy = yc - min_y;
    end
end
end