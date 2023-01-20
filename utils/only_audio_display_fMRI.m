function [response, onset] = only_audio_display_fMRI(p, audioname, start, event_start_time)
% Display video giving the file name
    response = NaN;
    
    sound_load(audioname,p.pahandle);

    while GetSecs < start+event_start_time
        
    end

    onset = GetSecs - start;
    sound_play(p.pahandle);
    
    tic;
    while toc < 1
        
        [keyIsDown, ~, keyCode] = KbCheck(-1);
        if (keyIsDown==1 && keyCode(p.escapeKey))
            % Set the abort-demo flag.
            error('Quit the experiment!');
        elseif (keyIsDown == 1 && keyCode(p.pressKey))
            response = 1;
        end
        
        Screen('DrawLines',p.whandle,p.fixcross,p.fixwidth,p.fixcolor);
        Screen('Flip', p.whandle);
    end


end

