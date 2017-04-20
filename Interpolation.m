clearvars;
close all;
clc;

% Known CMYK values from swatch book
% CMYK_Target Brick Grey [0,0.05,0.24,0.38]
% CMYK_Target Brick Grey Shadow [0.08,0,0.26,0.32]
% CMYK_Target Brick Grey Light[0,0.58,0.66,0.34]
% CMYK_Target Emergency Red [0 0.89 0.63 0.11]
% CMYK_Target Pale Yellow [0,0.06,0.27,0.06] % Cream Wall
% CMYK_Target Pebble Dash [0,0.05,0.25,0.22]
% CMYK_Target Dark Yellow [0,0.35,1,0]
% CMYK_Target Light Yellow [0,0.09,0.63,0.02]
% CMYK_Target Red Brick [0,0.58,0.66,0.34]
% CMYK_Target Tree Bark [0,0.17,0.4,0.6]
% CMYK_Target Fence [0.1,0,0.31,0.67]0.1,0,0.27,0.73
% CMYK_Target Purple Flower [0.07,0.45,0,0]
% CMYK_Target Dark Green Leaf [0.68,0,0.76,0.24]
% CMYK_Target Light Green Leaf [0.72,0,0.73,0.27]
% CMYK_Target Electricity Box [0,0,0,0.799]
% CMYK_targetUtility = [0,0.05,0.25,0.22; 0,0.05,0.25,0.22; 0,0.06,0.27,0.06; 0,0.06,0.27,0.06; 0.73,0,0.77,0.23];
CMYK_target = [0,0.52,0.56,0.42,0,0.05,0.24,0.38];

% Convert to RGB then to CIELab
RGB_target = cmyk2rgb(CMYK_target);
Lab_ideal = colorspace('RGB->LAB',(RGB_target))

% RGB Image
RGB_Image = imread('RedBrickWalla5.jpg');
Iblur = imgaussfilt(RGB_Image,4);
figure()
imshow(Iblur)
%%
% Dominant Colour Selection & Averaging
title('Dominant Colour Selection');
message = sprintf('Select the dominant colours.\nPress enter when colours are selected.');
uiwait(msgbox(message));
DominantColour1 = impixel;
DominantColour2 = impixel;
DC1 = size(DominantColour1);
DC2 = size(DominantColour2);
RGB_Dominant = [DominantColour1; DominantColour2];

CMYK_1 = repmat(Lab_ideal(1,:),DC1(1),1);
CMYK_2 = repmat(Lab_ideal(2,:),DC2(1),1);
Lab_ideal = [CMYK_1; CMYK_2];

% Number of Dominant Colours Selected
Size = size(RGB_Dominant);
N = Size(1);

% Conversion to CIELab
Lab_raw = colorspace('RGB->LAB',(RGB_Dominant./255))

% Convert the RGB image into the CIELab colour space
CIELab_Image = colorspace('RGB->LAB',(RGB_Image));

LShift = (Lab_ideal(:,1)-Lab_raw(:,1));
aShift = (Lab_ideal(:,2)-Lab_raw(:,2));
bShift = (Lab_ideal(:,3)-Lab_raw(:,3));
Colour_Difference = (LShift.^2 + aShift.^2 + bShift.^2).^(0.5);

VectorLPredict = scatteredInterpolant(Lab_raw(:,1),Lab_raw(:,2),Lab_raw(:,3), LShift,'natural','nearest'); 
VectoraPredict = scatteredInterpolant(Lab_raw(:,1),Lab_raw(:,2),Lab_raw(:,3), aShift,'natural','nearest'); 
VectorbPredict = scatteredInterpolant(Lab_raw(:,1),Lab_raw(:,2),Lab_raw(:,3), bShift,'natural','nearest'); 

ShiftersL = VectorLPredict(CIELab_Image(:,:,1),CIELab_Image(:,:,2),CIELab_Image(:,:,3));
Shiftersa = VectoraPredict(CIELab_Image(:,:,1),CIELab_Image(:,:,2),CIELab_Image(:,:,3));
Shiftersb = VectorbPredict(CIELab_Image(:,:,1),CIELab_Image(:,:,2),CIELab_Image(:,:,3));

Adjusted_Image(:,:,1) = CIELab_Image(:,:,1) + ShiftersL;
Adjusted_Image(:,:,2) = CIELab_Image(:,:,2) + Shiftersa;
Adjusted_Image(:,:,3) = CIELab_Image(:,:,3) + Shiftersb;

Adjusted_RGB_Image = im2uint8(colorspace('LAB->RGB',(Adjusted_Image)));
imshow(Adjusted_RGB_Image)
%Enlarge figure to full screen
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
title('Camouflage Image')

Adjusted_CMYK_Image = rgb2cmyk(Adjusted_RGB_Image);
imwrite(Adjusted_CMYK_Image,'RedBrickInterp.tiff')




