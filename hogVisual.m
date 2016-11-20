% Author: Nikhil Nagraj Rao
% PID: n3621940
% University of Central Florida
% 22 Oct 2014
% CAP 5415 - Programming Assignment 3

clear all
close all
%-------------------------------------------------------------------------------------------------

img = im2double(imread('img1.jpg'));
% Visualization Glyph Size
visuSize = 15;

% Set or Reset Boundary Processing - 'True' considers only the 64x128 window
% in a padded image as in the case of positive examples of INRIA dataset
boundaryFlg = 0;

% Flag controlling random cropping. Set to true in case of negative
% examples
cropFlg = false;

%-------------------------------------------------------------------------------------------------

% Gradient Mask
gradMask = [-1 0 1];

% Initializations
descriptor = [];
indx(1:3) = 0;
visu = cell(1, 1);
visuOverlap = cell(1, 1);

% Generating Glyphs for each orientation - Used for Visualization
glyph1 = zeros(visuSize, visuSize);
glyph1(round(visuSize/2):round(visuSize/2), :) = 255;
glyph = zeros([size(glyph1) 9]);
glyph(:,:,1) = glyph1;

for i = 2:9,
    glyph(:,:,i) = imrotate(glyph1, (i-1)*20, 'crop');
end

if(cropFlg)
    % Randomly crop a 64x128 window for negatives
    cropIndexRw = randi(size(img, 1) - 128);
    cropIndexCl = randi(size(img, 2) - 64);
    img = imcrop(img, [cropIndexCl cropIndexRw 63 127]);
end

% Gradient calculations
Ix = imfilter(img, gradMask, 'replicate');
Iy = imfilter(img, gradMask', 'replicate');

% Magnitude
gMagn = sqrt(Ix .* Ix + Iy .* Iy);

% Direction
gDir = atan2(Iy, Ix) + pi;
gDir(gDir > pi) = gDir(gDir > pi) - pi;
gDir = rad2deg(gDir);

% Select most dominant color channel for descriptor calculations
for i = 1:3
    indx(i) = max(max(gMagn(:, :, i)));
end
maxCh = find(indx == max(indx), 1);

% Get the descriptor and visualizations for each 16x6 block
m = 1;
for i = (16 + boundaryFlg*16): 8: size(img, 1) - boundaryFlg*16
    l = 1;
    for j = (16 + boundaryFlg*16): 8: size(img, 2) - boundaryFlg*16
        
        [blockDscptr, visu{m, l}] = findHistBlockVisu(gMagn(i-15:i, j-15:j, maxCh),...
            gDir(i-15:i, j-15:j, maxCh), glyph);
        l = l+1;
        
        % Concatenate descriptors
        descriptor = [descriptor blockDscptr];
        
    end
    m = m + 1;
end

% Eliminate overlap in the visualization
for i= 1:2:size(visu, 2)
    for j = 1:2:size(visu, 1)
        visuOverlap{ceil(j/2), ceil(i/2)} = visu{j, i};
    end
end

% Convert vsualization cells into an array
visu = cell2mat(visuOverlap);

imshow(visu);


