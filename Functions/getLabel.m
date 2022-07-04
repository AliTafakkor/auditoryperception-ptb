function label = getLabel(videoID)
%Get categorical label from videoID 1-80
    if videoID > 0 && videoID <= 20
        label = 'animals';
    elseif videoID > 20 && videoID <= 40
        label = 'objects';
    elseif videoID > 40 && videoID <= 60
        label = 'scenes';
    elseif videoID > 60 && videoID <= 80
        label = 'people';
    
    
end

