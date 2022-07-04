function displayRect = calculateDisplayRect(height, width, dispSize, centerX, centerY)
% given an arbitrary image size
% generate a rect size, centered on the Screen, that makes the maximum
% dimension equal to N pixels


aspectRatio = height/width;

if aspectRatio == 1
    % square
    newHeight = dispSize;
    newWidth = dispSize;
    
elseif aspectRatio > 1
    % tall
    newHeight = dispSize;
    newWidth = dispSize/aspectRatio;
    
else aspectRatio < 1
    % fat
    newWidth = dispSize;
    newHeight = dispSize * aspectRatio;
    
end

%rect = round([0 0 newWidth newHeight]);
rect = round([0 0 newHeight newWidth]);
displayRect = CenterRectOnPoint(rect, centerX, centerY);
end