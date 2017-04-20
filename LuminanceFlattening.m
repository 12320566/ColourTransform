function Adjusted_RGB_Image = LuminanceFlattening(Image)

figure
imshow(Image)
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% Pixel Location to be used as reference location
message = sprintf('Choose reference position (top left corner) for image adjustment.\nPress enter when you have selected it.');
uiwait(msgbox(message));
[col_pos,row_pos,P] = impixel;
close

% Reference luminance area for calculating average value
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
message = sprintf('Select area to be used as reference luminance area.\nDouble click the area when you have selected it.');
uiwait(msgbox(message));
[Reference] = imcrop(Image);

% Area to be adjusted
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
message = sprintf('Select area to be adjusted.\nDouble click the area when you have selected it.');
uiwait(msgbox(message));
[Adjusted_Area] = imcrop(Image);


% Conversion to CIELch
% Convert the RGB images into the CIELch colour space
CIELch_Image = colorspace('RGB->LCH',(Image));
Lch_Reference = colorspace('RGB->LCH',(Reference));
Lch_Image = colorspace('RGB->LCH',(Adjusted_Area));
Average_h = mean2(Lch_Reference(:,:,3));
Average_c = mean2(Lch_Reference(:,:,2));
Average_L = mean2(Lch_Reference(:,:,1));
STD_L = std2(CIELch_Image(:,:,1));
Lch_Image(:,:,3) = Average_h;
Lch_Image(:,:,2) = Average_c;

Image_Size = size(Lch_Image);
    for n = 1:Image_Size(1)
        for m = 1:Image_Size(2)
            if (abs(Lch_Image(n,m,1) - Average_L)> STD_L && (Lch_Image(n,m,1) - Average_L)>0)
                Lch_Image(n,m,1) =  Lch_Image(n,m,1)-STD_L;
            end
            if (abs(Lch_Image(n,m,1) - Average_L)> STD_L && (Lch_Image(n,m,1) - Average_L)<0)
                Lch_Image(n,m,1) =  Lch_Image(n,m,1)+STD_L;
            end
        end
    end

% Smooth the image
Lch_Image =  imgaussfilt(Lch_Image,7);

% Set starting position to be (0,0)
[n, m, ~] = size(Lch_Image);
n = n+(row_pos-1);
m = m+(col_pos-1);
CIELch_Image(row_pos:n,col_pos:m,:)= Lch_Image;
Adjusted_RGB_Image = im2uint8(colorspace('LCH->RGB',(CIELch_Image)));

