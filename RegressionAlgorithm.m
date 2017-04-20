yalmip('clear')
clearvars;
close all;
clc;

% Known CMYK values from swatch book
% CMYK_Target Brick Grey [0,0.05,0.24,0.38]
% CMYK_Target Brick Grey Shadow [0.08,0,0.26,0.32]
% CMYK_Target Brick Grey Light[0,0.04,0.23,0.53]
% CMYK_Target Emergency Red [0 0.89 0.63 0.11]
% CMYK_Target Pale Yellow [0,0.06,0.27,0.06]
% CMYK_Target Pebble Dash [0,0.05,0.25,0.22]
% CMYK_Target Dark Yellow [0,0.35,1,0]
% CMYK_Target Light Yellow [0,0.09,0.63,0.02]
% CMYK_Target Red Brick [0,0.58,0.66,0.34]
% CMYK_Target Red Brick Cement [0,0.05,0.25,0.3]
% CMYK_Target Tree Bark [0,0.17,0.4,0.6]
% CMYK_Target Fence [0.1,0,0.31,0.67]0.1,0,0.27,0.73
% CMYK_Target Purple Flower [0.07,0.45,0,0]
CMYK_target = [0,0.52,0.56,0.42,0,0.05,0.24,0.38];

% Convert to RGB then CIELab
RGB_target = cmyk2rgb(CMYK_target);
Lab_ideal = colorspace('RGB->LAB',(RGB_target));

% RGB Image Manipulation
RGB_Image = imread('RedBrickWalla5.jpg');

%%
figure
imshow(RGB_Image)
% Enlarge figure to full screen
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% Pixel Location to be used as reference location
message = sprintf('Choose reference position (top left corner) for camouflage.\nPress enter when you have selected it.');
uiwait(msgbox(message));
[col_pos,row_pos,P] = impixel;
close

% Find the size of the object to be camouflaged
% Display the original image.
handleToAxes = subplot(1, 2, 1);
imshow(RGB_Image);
title('Original Image');
% Enlarge figure to full screen.
set(gcf, 'Position', get(0,'Screensize'));

message = sprintf('Draw a box of the area to be camouflaged.\nDouble click the area when you have selected it.');
uiwait(msgbox(message));

% croppedImage = imcrop(handleToAxes);
[Camouflage_Object,rect] = imcrop(RGB_Image);

% Dominant Colour Selection & Averaging
Iblur = imgaussfilt(RGB_Image,4);
subplot(1, 2, 2);
imshow(Iblur)
title('Dominant Colour Selection');
message = sprintf('Select the dominant colours.\nPress enter when colours are selected.');
uiwait(msgbox(message));
Dominant_RGB = impixel;
close

% Number of Dominant Colours Selected
Size = size(Dominant_RGB);
N = Size(1);

% Conversion to CIELAB
Lab_raw = colorspace('RGB->LAB',(Dominant_RGB./255));

% Minimise the colour difference between the raw and ideal values in CIELAB
controlVariables = MinimiseColifference(Lab_ideal,Lab_raw,N);

% Convert the RGB image into the CIELAB colour space
CIELab_Image = colorspace('RGB->LAB',(RGB_Image));
CIELab_Camouflage = colorspace('RGB->LAB',(Camouflage_Object));

% Adjust the image according to the optimised control variables
Image_Size = size(CIELab_Camouflage);
for i = 1:Image_Size(3)
    for n = 1:Image_Size(1)
        for m = 1:Image_Size(2)
                CIELab_Camouflage(n,m,i) =  CIELab_Camouflage(n,m,i)+controlVariables(i);
        end
    end
end

[n, m, ~] = size(CIELab_Camouflage);
n = n+(row_pos-1);
m = m+(col_pos-1);
CIELab_Image(row_pos:n, col_pos:m,:)= CIELab_Camouflage;

%Convert to RGB
Adjusted_RGB_Image = im2uint8(colorspace('LAB->RGB',(CIELab_Image)));
imshow(Adjusted_RGB_Image)
% Enlarge figure to full screen
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
title('Camouflage Image')

% Convert to CMYK
Adjusted_CMYK_Image = rgb2cmyk(Adjusted_RGB_Image);
imwrite(Adjusted_CMYK_Image,'AdjustedRedBrickLab.tiff')








