


% Instruction text
str = 'Now it is visual imagery task. You will hear sounds of videos, and meawhile please imagine';
Screen('DrawText', p.whandle, str, p.xCenter-1000, p.yCenter-100, [0 0 0]);
str = 'the associated visual.';
Screen('DrawText', p.whandle, str, p.xCenter-1000, p.yCenter, [0 0 0]);

str = 'When you are ready, press ‘s’ button to start.';
Screen('DrawText', p.whandle, str, p.xCenter-500, p.yCenter+200, [0 0 0]);

Screen('Flip', p.whandle);


% Press s to continue
while 1
    [~, keyCode, ~] = KbWait([], 2);
    if keyCode(startKey)
        break;
    end
end


% Start
for i = to_play
    
    videoID = trials(i);
    % Instruction text
    str = 'Press any button to play the sound and imagine the visual scenes';
    Screen('DrawText', p.whandle, str, p.xCenter-750, p.yCenter, [0 0 0]);
    Screen('Flip', p.whandle);
    
    KbWait([], 2);
    
    % Play the sound
    audioname = [pwd audio(videoID).videoName(2:end)];
    sound_load(audioname,p.pahandle);
    sound_play(p.pahandle);
    
    WaitSecs(1);
    
    % Instruction to rate the vividness
    str = 'Please rate the vividness of your visual imagery';
    Screen('DrawText', p.whandle, str, p.xCenter-600, p.yCenter-400, [0 0 0]);
    str = '1 - No visual at all';
    Screen('DrawText', p.whandle, str, p.xCenter-400, p.yCenter-200, [0 0 0]);
    str = '2 - Vague and dim';
    Screen('DrawText', p.whandle, str, p.xCenter-400, p.yCenter-100, [0 0 0]);
    str = '3 - Moderately clear and vivid';
    Screen('DrawText', p.whandle, str, p.xCenter-400, p.yCenter, [0 0 0]);
    str = '4 - Clear and reasonably vivid';
    Screen('DrawText', p.whandle, str, p.xCenter-400, p.yCenter+100, [0 0 0]);
    str = '5 - Perfectly clear and as vivid as normal vision';
    Screen('DrawText', p.whandle, str, p.xCenter-400, p.yCenter+200, [0 0 0]);
    Screen('Flip', p.whandle);
    
    
    % Wait until press 1 - 5
    while 1
        [~, keyCode,~] =  KbWait([], 2);
        if keyCode(videoPlayKey) || keyCode(audioPlayKey) || keyCode(silentvideoPlayKey) || keyCode(KbName('4$')) || keyCode(KbName('5%'))
            break;
        end
    end
    
    % Record responses
    if keyCode(videoPlayKey)
        visual_response(n_visual,videoID) = 1;
    elseif keyCode(audioPlayKey)
        visual_response(n_visual,videoID) = 2;
    elseif keyCode(silentvideoPlayKey)
        visual_response(n_visual,videoID) = 3;
    elseif keyCode(KbName('4$'))
        visual_response(n_visual,videoID) = 4;
    elseif keyCode(KbName('5%'))
        visual_response(n_visual,videoID) = 5;
    end
    
    
    
    % Replay the video until press right arrow
    while 1
        
        %Instruction texts
        str = ['You can now replay the video to refresh your memory.'];
        Screen('DrawText', p.whandle, str, p.xCenter- 600, p.yCenter-600, [0 0 0]);
        str = ['Press 1 to watch video.   Press 2 to play only the sound.   Press 3 to play the silent video.'];
        Screen('DrawText', p.whandle, str, p.xCenter-1000, p.yCenter-500, [0 0 0]);
        str = ['Press ‘right arrow’ to continue.'];
        Screen('DrawText', p.whandle, str, p.xCenter-1000, p.yCenter-440, [0 0 0]);
        Screen('Flip', p.whandle);
        [~, keyCode, ~] = KbWait([], 2);
        
        
        if keyCode(videoPlayKey)
            moviename = [pwd videos(videoID).videoName(2:end)];
            audioname = [pwd audio(videoID).videoName(2:end)];
            video_audio_display(p,moviename,audioname)
        elseif keyCode(audioPlayKey)
            audioname = [pwd audio(videoID).videoName(2:end)];
            sound_load(audioname,p.pahandle);
            sound_play(p.pahandle);
        elseif keyCode(silentvideoPlayKey)
            moviename = [pwd videos(videoID).videoName(2:end)];
            video_display(p, moviename)
        elseif keyCode(nextPlayKey)
            break;
        end
        
    end
    
    
    
    
end