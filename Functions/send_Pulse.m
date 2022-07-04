function send_Pulse(device, numstim, duration)
% for each stimuli, send pulse f

if strcmp(class(device), 'internal.Serialport')
    %By default the pulse duration is set to 0, which is "indefinite".
    %You can either set the necessary pulse duration, or simply lower the lines
    %manually when desired.
    setPulseDuration(device, duration)
    
    %mh followed by two bytes of a bitmask is how you raise/lower output lines.
    %Not every XID device supports 16 bits of output, but you need to provide
    %both bytes every time.
    
    write(device,sprintf("mh%c%c", numstim, 0), "char")
    
end
function byte = getByte(val, index)
byte = bitand(bitshift(val,-8*(index-1)), 255);
end

function setPulseDuration(device, duration)
%mp sets the pulse duration on the XID device. The duration is a four byte
%little-endian integer.
write(device, sprintf("mp%c%c%c%c", getByte(duration,1),...
    getByte(duration,2), getByte(duration,3),...
    getByte(duration,4)), "char")


end
end

