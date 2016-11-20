% Author: Nikhil Nagraj Rao
% PID: n3621940
% University of Central Florida
% 10 Nov 2014
% CAP 5415 - Programming Assignment 3


clear;
clc;
close all;
% Load the training data previously saved
load('Results/Wb.mat');

% Maximum Pyramid Depth
pyrDpth = 10;

% Threshold
thresh = 1.0;
% Step Size for sliding window
% Note: The size will be adjusted based on the pyramid level
stepSize = 20;

% Bounding Box overlap threshold
olThresh = 0.1;

% Input Image
imgFull = im2double(imread('testImgs/pos/1.jpg'));

% Generate Image Pyramid
imgPyr{1, 1} = imgFull;

for i= 2: pyrDpth
    imgPyr{1, i} = impyramid(imgPyr{1, i-1}, 'reduce');
end

% Gradient Mask
gradMask = [-1 0 1];

% Fing the HOG descriptor for every window position at every possible
% scalespace
% Note: The maximum number of pyramid levels depend on the size of the
% image. Any pyramid level cannot go smaller than 64x128 which is the size
% of the window.
for p=1:pyrDpth
    % Adjust the sliding window stepsize for every pyramid level
    stepSize = ceil(stepSize/2);
    
    % Calculate the HOG at every possible window position.
    for r = 1:stepSize:size(imgPyr{1,p}, 1) - 128
        for c= 1:stepSize:size(imgPyr{1,p}, 2) - 64
            descriptor = [];
            img = imgPyr{1,p}(r:r+127, c:c+63, :);
            
            % Gradient calculations
            Ix = imfilter(img, gradMask, 'replicate');
            Iy = imfilter(img, gradMask', 'replicate');
            
            % Magnitude
            gMagn = (Ix .* Ix + Iy .* Iy).^0.5;
            % Direction
            gDir = atan2(Iy, Ix) + pi;
            gDir(gDir > pi) = gDir(gDir > pi) - pi;
            gDir = gDir.*180/pi;
            
            % Select most dominant color channel for descriptor calculations
            for i = 1:3
                indx(i) = max(max(gMagn(:, :, i)));
            end
            maxCh = find(indx == max(indx), 1);
            
            % Get the descriptor only for each 16x6 block
            for i = 16: 8: 128
                for j = 16: 8: 64
                    
                    blockDscptr = findHistBlock(gMagn(i-15:i, j-15:j, maxCh), ...
                        gDir(i-15:i, j-15:j, maxCh));
                    
                    % Concatenate descriptors
                    descriptor = [descriptor blockDscptr];
                    
                end
            end
            
            % Calculatethe scores and accumulate the scores in an array
            dataDscptrPos(ceil(r/stepSize), ceil(c/stepSize), p) = ...
                descriptor * Wb(1:3780) + Wb(3781);
            % Store the location of the window in the original image
            loc{ceil(r/stepSize), ceil(c/stepSize), p} = [r c];
            
        end
    end
end

% Make all negative window scores zero.
dataDscptrPos(dataDscptrPos < thresh) = 0;

% Clear unwanted variables
clear blockDscptr r  c descriptor gDir gMagn gradMask i  img indx Ix Iy j maxChp Wb

% Find the positive score location and values
ind(:,1) = find(dataDscptrPos > 0);
ind(:,2) = dataDscptrPos(ind);

% Go further only if a positive score was found(i.e a human was detected). Else simply diplay the
% input image.
if (size(ind, 1) > 0)
    % Sort the indexes based on the confidence scores.
    ind = -sortrows(-ind, 2);
    % Get the spatial co-ordinates from indexed addressing.
    [bBoxR, bBoxC, scale] = ind2sub(size(dataDscptrPos), ind(:, 1));
    
    % Generate bounding boxes scaled by the scalespace in which they were
    % detected for each postive score value.
    for i = 1: size(ind)
        a(i, :) = loc{bBoxR(i), bBoxC(i), scale(i)};
        fctr = 2^(scale(i)-1);
        bBox{i, 1} = [a(i, 2) * fctr, a(i, 1) * fctr, 64 * fctr, 128 * fctr];
    end
    
    % Flag to identify if a bounding box was discarded
    deleteFlag(1:size(bBox)) = false;
    
   % Loop through all bounding boxes and discard them if their overlap
   % satisfies the criterion
    for i = 1:size(bBox) - 1
        if(deleteFlag(i) == false)
            for j = i+1 : size(bBox)
                % Intersection Area
                intArea = rectint(bBox{i, 1}, bBox{j, 1});
                % Union Area
                uniArea = (bBox{i, 1}(1, 3) * bBox{i, 1}(1, 4)) +...
                    (bBox{j,1}(1, 3) * bBox{j,1}(1, 4)) - intArea;
                % Check if intersection satisfies condition OR the box lies
                % within the bigger box
                if(intArea/uniArea > olThresh) || (intArea == bBox{j, 1}(1, 3) * bBox{j, 1}(1, 4))
                    % If true, discard the bounding box
                    deleteFlag(j) = true;
                end
            end
        end
    end
    
    % Display the input image
    imshow(imgFull);
    
    % Display all bounding boxes which were preserved on the displayed
    % input image
    for i =1: size(bBox)
        % Check if the bounding box was preserved
        if deleteFlag(i) == false
            rectangle('Position', bBox{i, 1}, 'EdgeColor', 'r');
        end
    end
else
    % In case no human was detected, simply display the input image
    imshow(imgFull);
end











