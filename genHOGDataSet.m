% Author: Nikhil Nagraj Rao
% PID: n3621940
% University of Central Florida
% 22 Oct 2014
% CAP 5415 - Programming Assignment 3

clear all
close all

folder_path_pos = 'Filtered/pos/';
folder_path_neg = 'Filtered/neg/';

% Set or Reset Boundary Processing - 'True' considers only the 64x128 window
% in a padded image as in the case of positive examples of INRIA dataset
boundaryFlg = 1;

% Gradient Mask
gradMask = [-1 0 1];
indx(1:3) = 0;
dataDscptrPos(1:2416, 1:3280) = [];
dataDscptrNeg(1:912, 1:3280) = [];

% Calculate HOG for all positive examples
for l = 1:2416
    descriptor = [];
    img = im2double(imread([folder_path_pos num2str(l) '.png']));
    
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
    
    % Get the descriptor only for each 16x6 block
    for i = (16 + boundaryFlg*16): 8: size(img, 1) - boundaryFlg*16
        for j = (16 + boundaryFlg*16): 8: size(img, 2) - boundaryFlg*16
            
            blockDscptr = findHistBlock(gMagn(i-15:i, j-15:j, maxCh), ...
                gDir(i-15:i, j-15:j, maxCh));
            
            % Concatenate descriptors
            descriptor = [descriptor blockDscptr];
            
        end
    end
    
    % Accumulate the decriptors in an array
    dataDscptrPos(l, :) = descriptor;
end

% Save the descriptors
save('Descriptors/dataDscptrPos.mat', 'dataDscptrPos');


% Calculate HOG for all negative examples
boundaryFlg = 0;
for l = 1:912
    descriptor = [];
    img = im2double(imread([folder_path_neg num2str(l) '.png']));
    
    % Randomly crop a 64x128 window for negatives
    cropIndexRw = randi(size(img, 1) - 128);
    cropIndexCl = randi(size(img, 2) - 64);
    img = imcrop(img, [cropIndexCl cropIndexRw 63 127]);
    
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
    
    % Get the descriptor only for each 16x6 block
    for i = (16 + boundaryFlg*16): 8: size(img, 1) - boundaryFlg*16
        for j = (16 + boundaryFlg*16): 8: size(img, 2) - boundaryFlg*16
            
            blockDscptr = findHistBlock(gMagn(i-15:i, j-15:j, maxCh), ...
                gDir(i-15:i, j-15:j, maxCh));
            
            % Concatenate descriptors
            descriptor = [descriptor blockDscptr];
            
        end
    end
    
    % Accumulate the decriptors in an array
    dataDscptrNeg(l, :) = descriptor;
end

% Save the descriptors
save('Descriptors/dataDscptrNeg.mat', 'dataDscptrNeg');

clear all;
