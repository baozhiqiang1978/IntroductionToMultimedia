%# Initializations:
inputImage = imread('clash3.png'); 
figure, imshow(inputImage)
multiple = [4 4];              %# The resolution scale factors: [rows columns]
oldSize = size(inputImage);                   %# Get the size of your image
newSize = max(floor(multiple.*oldSize(1:2)),1);  %# Compute the new image size
rowIndex = min(round(((1:newSize(1))-0.5)./multiple(1)+0.5),oldSize(1));
colIndex = min(round(((1:newSize(2))-0.5)./multiple(2)+0.5),oldSize(2));
figure, imshow(inputImage(rowIndex,colIndex,:))

%---------------------------------------
 %// Get some necessary variables first

img = imread('clash3.png');
in_rows = size(img,1);
in_cols = size(img,2);
out_rows = size(img,1)*4;
out_cols = size(img,1)*4;   
ratio_X = in_rows / out_rows;
ratio_Y = in_cols / out_cols;
[newY, newX] = meshgrid(1 : out_cols, 1 : out_rows);
newX = newX * ratio_X;
newY = newY * ratio_Y;
x = floor(newX);
y = floor(newY);
x(x < 1) = 1;
y(y < 1) = 1;
x(x > in_rows - 1) = in_rows - 1;
y(y > in_cols - 1) = in_cols - 1;
delta_X = newX - x;
delta_Y = newY - y;
in1_ind = sub2ind([in_rows, in_cols], x, y);
in2_ind = sub2ind([in_rows, in_cols], x+1,y);
in3_ind = sub2ind([in_rows, in_cols], x, y+1);
in4_ind = sub2ind([in_rows, in_cols], x+1, y+1);       
out = zeros(out_rows, out_cols, size(img, 3));
out = cast(out, class(img));
    for idx = 1 : size(img, 3)
        chan = double(img(:,:,idx)); %// Get i'th channel
        %// Interpolate the channel
        tmp = chan(in1_ind).*(1 - delta_X).*(1 - delta_Y) + ...
                       chan(in2_ind).*(delta_X).*(1 - delta_Y) + ...
                       chan(in3_ind).*(1 - delta_X).*(delta_Y) + ...
                       chan(in4_ind).*(delta_X).*(delta_Y);
        out(:,:,idx) = cast(tmp, class(img));
    end
    figure,imshow(out)