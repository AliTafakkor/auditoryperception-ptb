function [resp,respTime] = button_response_time(waittime,pressKey)

resp = NaN;

%wait for key
respTime = NaN;

tic

while toc < waittime
    
     
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(-1);
    
    if keyIsDown ~=0 && keyCode(pressKey)%if key pressed
        resp = 1;
        respTime = toc;
        
%         if keyCode(81) %Q key
%             sca
%             return
%         end

    end
 
end

% [secs, keyCode, deltaSecs] = KbWait([],0,waittime);
% 
% if keyCode(32) == 1
%     resp = 1;
%     respTime = toc;
%     
% end
    
end


