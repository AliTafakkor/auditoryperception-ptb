function [response, loadtime, wholetime] = video_audio_display(p,moviename,audioname)
% Display video giving the file name
    response = NaN;
    
    tic;
    %loadstart = GetSecs;
    % Open movie file and retrieve basic info about movie:
    [movie] = Screen('OpenMovie', p.whandle, char(moviename));
    
    % Start playback of movie
    Screen('PlayMovie', movie, 1, 0, 1);
    
    %t1 = GetSecs;
    
    sound_load(audioname,p.pahandle);

    loadtime = toc;
    
    sound_play(p.pahandle);
    % Fetch video frames and display them...
    while 1
        
        [keyIsDown, ~, keyCode] = KbCheck(-1);
        if (keyIsDown==1 && keyCode(p.escapeKey))
            % Set the abort-demo flag.
            error('Quit the experiment!');
        elseif (keyIsDown == 1 && keyCode(p.pressKey))
            response = 1;
        end
        
        tex = Screen('GetMovieImage', p.whandle, movie);
        
        % Valid texture returned?
        if tex < 0
            % No, and there won't be any in the future, due to some
            % error. Abort playback loop:
            break;
        end
        
        
        % Draw the new texture immediately to screen:
        Screen('DrawTexture', p.whandle, tex);
        Screen('DrawLines',p.whandle,p.fixcross,p.fixwidth,p.fixcolor);
        
        % Update display:
        Screen('Flip', p.whandle);
        
        % Release texture:
        Screen('Close', tex);
        
    end
    
    Screen('Flip', p.whandle);

    
    % Done. Stop playback:
    Screen('PlayMovie', movie, 0);
    
    % Close movie object:
    Screen('CloseMovie', movie);

    wholetime = toc; %GetSecs - loadstart;

    


end

