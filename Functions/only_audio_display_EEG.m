function [response, loadtime, wholetime] = only_audio_display_EEG(p,audioname,device,videoID,duration)
% Display video giving the file name
    response = NaN;
    
    tic;
    
    
    sound_load(audioname,p.pahandle);

    loadtime = toc;
    
    send_Pulse(device, videoID, duration);
    sound_play(p.pahandle);
    
    while toc < 1
        
        Screen('DrawLines',p.whandle,p.fixcross,p.fixwidth,p.fixcolor);
        Screen('DrawDots', p.whandle, [2550 10],100, [255 255 255],[0 0],4)
        
        Screen('Flip', p.whandle);
        
        [keyIsDown, ~, keyCode] = KbCheck(-1);
        if (keyIsDown==1 && keyCode(p.escapeKey))
            % Set the abort-demo flag.
            error('Quit the experiment!');
        elseif (keyIsDown == 1 && keyCode(p.pressKey))
            send_Pulse(device, 128, 50);
            response = 1;
        end
        % Draw the new texture immediately to screen:
        
        
        
        
    end

    wholetime = toc; %GetSecs - loadstart;

    


end

