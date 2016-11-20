% Author: Nikhil Nagraj Rao
% PID: n3621940
% University of Central Florida
% 22 Oct 2014
% CAP 5415 - Programming Assignment 3

function [histBlock, visIm] = findHistBlockVisu(gradMag, gradDir, visElmt)

% Visualization cell
visBlock = cell(2, 4);

histBlock = [];

% Calculate the HOG for each 8x8 cell in the 16x16 block
for i= 0:1
    for j= 0:1
        histCell = zeros(1, 9);
        cellDir = gradDir(8*i+1:8*i+8, 8*j+1:8*j+8);
        cellMag = gradMag(8*i+1:8*i+8, 8*j+1:8*j+8);
        
        for x=1:8
            for y=1:8
                k = cellDir(x, y);
                
                % Interpolation between bins
                if k>=0 && k<=10
                    histCell(1) = histCell(1) + cellMag(x,y);
                elseif k>10 && k<=30
                    histCell(1) = histCell(1) + cellMag(x,y) * (30-k)/20;
                    histCell(2) = histCell(2) + cellMag(x,y) * (k-10)/20;
                elseif k>30 && k<=50
                    histCell(2) = histCell(2) + cellMag(x,y) * (50-k)/20;
                    histCell(3) = histCell(3) + cellMag(x,y) * (k-30)/20;
                elseif k>50 && k<=70
                    histCell(3) = histCell(3) + cellMag(x,y) * (70-k)/20;
                    histCell(4) = histCell(4) + cellMag(x,y) * (k-50)/20;
                elseif k>70 && k<=90
                    histCell(4) = histCell(4) + cellMag(x,y) * (90-k)/20;
                    histCell(5) = histCell(5) + cellMag(x,y) * (k-70)/20;
                elseif k>90 && k<=110
                    histCell(5) = histCell(5) + cellMag(x,y) * (110-k)/20;
                    histCell(6) = histCell(6) + cellMag(x,y) * (k-90)/20;
                elseif k>110 && k<=130
                    histCell(6) = histCell(6) + cellMag(x,y) * (130-k)/20;
                    histCell(7) = histCell(7) + cellMag(x,y) * (k-110)/20;
                elseif k>130 && k<=150
                    histCell(7) = histCell(7) + cellMag(x,y) * (150-k)/20;
                    histCell(8) = histCell(8) + cellMag(x,y) * (k-130)/20;
                elseif k>150 && k<=170
                    histCell(8) = histCell(8) + cellMag(x,y) * (170-k)/20;
                    histCell(9) = histCell(9) + cellMag(x,y) * (k-150)/20;
                elseif k>170 && k<=180
                    histCell(9) = histCell(9) + cellMag(x,y) * (190-k)/20;
                end
            end
        end
        % Append the descriptor
        histBlock = [histBlock histCell];
        
    end
end

%   histBlock = histBlock / norm(histBlock, 2);

% Calculate visualization element for each block
for k = 0:9:27
    visBlock{1, k/9 +1} = zeros(size(visElmt, 1));
    
    visBlock{1, k/9 + 1} = visBlock{1, k/9 +1} + histBlock(1, k+1).* visElmt(:, :, 1) + ...
        histBlock(1, k+2).* visElmt(:, :, 2) + ...
        histBlock(1, k+3).* visElmt(:, :, 3) + ...
        histBlock(1, k+4).* visElmt(:, :, 4) + ...
        histBlock(1, k+5).* visElmt(:, :, 5) + ...
        histBlock(1, k+6).* visElmt(:, :, 6) + ...
        histBlock(1, k+7).* visElmt(:, :, 7) + ...
        histBlock(1, k+8).* visElmt(:, :, 8) + ...
        histBlock(1, k+9).* visElmt(:, :, 9);
end

% Rearrange visualization cells
visBlock{2, 1} = visBlock{1, 3}; visBlock{1, 3} = [];
visBlock{2, 2} = visBlock{1, 4}; visBlock{1, 4} = [];

% Convert into matrix
visIm = uint8(cell2mat(visBlock));



