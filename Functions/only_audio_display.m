function [response, loadtime, wholetime] = only_audio_display(p,audioname)
% Display video giving the file name
    response = NaN;
    
    tic;
    
    
    sound_load(audioname,p.pahandle);

    loadtime = toc;
    
    sound_play(p.pahandle);
    
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

    wholetime = toc; %GetSecs - loadstart;

    


end

