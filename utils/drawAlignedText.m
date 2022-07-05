function drawAlignedText(p, str, voffset, voffset_lines, valign, halign)
    
    if nargin < 5
        halign = 'left';
        valign = 'top';
    end

    text_size = Screen('TextBounds', p.whandle, str);
    
    if strcmp(halign, 'left') || strcmp(halign, 'l')
        x = p.hpad;
    elseif strcmp(halign, 'center') || strcmp(halign, 'c')
        x = p.xCenter-text_size(3)/2;
    elseif strcmp(halign, 'right') || strcmp(halign, 'r')
        x = p.wRect(3)-text_size(3)-p.hpad;
    else
        error('Invalid horizontal align argument!')
    end

    if strcmp(valign, 'top') || strcmp(valign, 't')
        y = p.hpad + (text_size(4)+p.margin)*voffset_lines;
    elseif strcmp(valign, 'center') || strcmp(valign, 'c')
        y = p.hpad + (text_size(4)+p.margin)*voffset_lines - text_size(4)/2;
    elseif strcmp(valign, 'bottom') || strcmp(valign, 'b')
        y = p.hpad + (text_size(4)+p.margin)*voffset_lines + text_size(4)/2;
    else
        error('Invalid vertical align argument!')
    end

    y = y + voffset;

    Screen('DrawText', p.whandle, str, x, y, [0 0 0]);
end