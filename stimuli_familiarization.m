sca; clear; clc;

% Add path to utility functions
addpath('utils');

% Skip synchronization checks
%Screen('Preference', 'SkipSyncTests', 1);
AssertOpenGL;

% Initialize with unified keynames and normalized colorspace:
PsychDefaultSetup(2);
% Force GetSecs and WaitSecs into memory to avoid latency later on:
dummy=GetSecs;  
WaitSecs(0.1);

% Set parameters
p.text_size = 30;
p.text_font = 'Arial';

% Set experimental infotmation
exp.name = 'Stimuli_Familiarization';
exp.numStim = 80;
exp.numCategory = 4;
exp.timPerStim = 1;

% Get subject name
exp.subjID = input('Name of subject: ', 's');

% Setup key mapping:
p.nextKey = KbName('RIGHTARROW');
p.previousKey = KbName('LEFTARROW');
p.repeatKey = KbName('DOWNARROW');
p.escapeKey = KbName('ESCAPE');
p.spaceKey = KbName('SPACE');
p.pressKey = p.spaceKey;

% Load audio files
stimuli_folder = fullfile('.', 'stimuli');
categories = ["animals", "objects", "people", "scenes"];

ite = 1;
for category = categories
    files = dir(fullfile(stimuli_folder, category, '*.mp3'));
    for i=1:size(files,1)
        audio(ite).audioNameShort = files(i).name(1:end-4);
        files(i).name = char(fullfile(stimuli_folder, category, files(i).name));
        audio(ite).ID = ite;
        audio(ite).name = files(i).name;
        
        ite = ite + 1; 
    end
end

% Load oddball
oddball = fullfile('.', 'stimuli', 'noise.wav');

% Save audio information
audio(81).ID = 81;
audio(81).name = oddball;
audio(81).audioNameShort = 'oddball';
exp.stim = audio;


exp.date = nowstring;
save_path = fullfile('..', 'results', exp.subjID);

if ~isfolder(save_path)
    mkdir(save_path);
end 

save_file_name = fullfile(save_path, sprintf('%s_%s_%s.mat', exp.name, exp.subjID, exp.date));

% Load audio device
InitializePsychSound;
p.pahandle = PsychPortAudio('Open', [], [], 0, 48000, 2);

% Load silent audio to buffer
sound_load(fullfile('.', 'stimuli', 'silence.wav'), p.pahandle);
sound_play(p.pahandle);

%try
    
    % Open onscreen window with gray background:
    screenID = max(Screen('Screens'));
    PsychImaging('PrepareConfiguration');
    
    [p.whandle, p.wRect] = Screen('OpenWindow', screenID, [127 127 127]);
    p.xCenter = floor(p.wRect(3)/2);
    p.yCenter = floor(p.wRect(4)/2);
    p.hpad = p.wRect(3)*0.05;
    p.vpad = p.wRect(4)*0.05;
    p.margin = p.wRect(4)*0.025;

    Screen('BlendFunction', p.whandle, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('TextSize', p.whandle, p.text_size);
    HideCursor(p.whandle);
    
    % Wait Screen
    str = 'Please wait for set up.';
    drawAlignedText(p, str, 0, 2, 't', 'c')
    
    str = 'You will be told when it is ready to start.';
    drawAlignedText(p, str, 0, 3, 't', 'c')

    str = 'Thank you!';
    drawAlignedText(p, str, 0, 5, 't', 'c')

    str = 'CNAI lab!';
    drawAlignedText(p, str, p.wRect(4), -3, 'c', 'c')

    Screen('Flip', p.whandle);

    KbWait([], 2);

    % Instructions screen
    str = 'In this section you will hear a series of sounds and see a short decription along side them.';
    drawAlignedText(p, str, 0, 1, 't', 'l')
    
    str = 'You can repeat any sound as many times as you want till you feel familiar with it.';
    drawAlignedText(p, str, 0, 3, 't', 'l')

    str = 'Use the following buttons to navigate through sounds:';
    drawAlignedText(p, str, 0, 5, 't', 'l')

    str = 'Right arrow (→): next sound';
    drawAlignedText(p, str, 0, 6, 't', 'l')
    str = 'Left arrow (←): previous sound';
    drawAlignedText(p, str, 0, 7, 't', 'l')
    str = 'Down arrow (↓): repeat sound';
    drawAlignedText(p, str, 0, 8, 't', 'l')

    str = 'Press any key to start.';
    drawAlignedText(p, str, 0, 10, 't', 'l')

    Screen('Flip', p.whandle);

    % Wait for button press
    KbWait([], 2);
    
    randind = randperm(81);
    n = 1;
    while (true)
        ID = randind(n);
        audioname = [pwd audio(ID).name(2:end)];
        %description = audio(ID).description;

        % Load and Play the sound
        sound_load(audioname,p.pahandle);
        sound_play(p.pahandle);
        
        % Show description
        
        
        % Control buttons
        WaitSecs(1); 
        KbWait([], 2);
        if (keyIsDown==1 && keyCode(p.nextKey))
            n = n + 1;
        elseif (keyIsDown==1 && keyCode(p.previousKey))
            n = n - 1;
        elseif (keyIsDown==1 && keyCode(p.repeatKey))
            continue;
        else
            break;
        end
        %[response, loadtime, wholetime] = only_audio_display_EEG(p, audioname, device, ID, 1000);
    end

    % Close audio port
    PsychPortAudio('Close', p.pahandle);

    % Show cursor again:
    ShowCursor(p.whandle);
    
    % Close screens.
    sca;

%     for r = 1:12  % 12 runs
%         
%         run.runNumber = r;
%         
%         % Instruction text
%         
%         if r == 1 % first run
%             str = 'You will hear a series of sounds. Please imagine the associated visual.';
%             Screen('DrawText', p.whandle, str, p.xCenter-880, p.yCenter-400, [0 0 0]);
%             
%             str = 'Always close your eyes when doing this task. Place your finger on the space bar. When you hear a';
%             Screen('DrawText', p.whandle, str, p.xCenter-880, p.yCenter-200, [0 0 0]);
%             
%             str = 'noise sound, press the key. I will knock the door when one run ends, so you do not need to open ';
%             Screen('DrawText', p.whandle, str, p.xCenter-880, p.yCenter-100, [0 0 0]);
%             
%             str = 'your eyes to check.';
%             Screen('DrawText', p.whandle, str, p.xCenter-880, p.yCenter, [0 0 0]);
%             
%             str = 'There will be 12 runs. Each run will last 4.5 minutes.';
%             %str = ' 2) Always fixate on the center of the screen.';
%             Screen('DrawText', p.whandle, str, p.xCenter-880, p.yCenter+150, [0 0 0]);
%             
%             str = 'Close your eyes and press space key to start';
%             Screen('DrawText', p.whandle, str, p.xCenter-400, p.yCenter+350, [0 0 0]);
%             Screen('Flip', p.whandle);
%             % Wait for button press
%             KbWait([], 2);
%             
%         else
%             str = ['You have ' int2str(13-r) ' runs left. You can take a short break now.'];
%             Screen('DrawText', p.whandle, str, p.xCenter-850, p.yCenter-200, [0 0 0]);
%             str = 'When you are ready to start next run, you can press the space key to start.';
%             Screen('DrawText', p.whandle, str, p.xCenter-850, p.yCenter-100, [0 0 0]);
%             
%             str = 'If you do not press to start, next run will start automatically in 2 minutes.';
%             Screen('DrawText', p.whandle, str, p.xCenter-850, p.yCenter+50, [0 0 0]);
%             Screen('Flip', p.whandle);
%             % Wait for button press
%             tic
%             while toc < 120
%                 if KbCheck(-1)
%                     break;
%                 end
%             end
%             
%         end
%         
%         WaitSecs(2);
%         % Start master clock
%         run.startTime = GetSecs; %This becomes time zero
%         
%         % Start run
%         trials = randperm(80); % randomize the audio diplay order
%         
%         % Send trigger at the begining of each run, duration is 10 ms
%         send_Pulse(device, runStart, 10);
%         
%         i = 1; %used for mark each trial event
%         
%         % Generate random sequence for display noise audios
%         play_oddball = [ones(1,exp.numOdd) zeros(1,70)];
%         play_oddball = play_oddball(randperm(80));
%         clear explog
%         for n = 1:80
%             
%             % Play stimuli
%             t = GetSecs-run.startTime;
%             
%             ID = trials(n);
%             
%             explog(i).eventStartTime = t;
%             explog(i).eventLabel = getLabel(ID);
%             explog(i).ID = ID;
%             explog(i).response = NaN;
%             explog(i).name = audio(ID).name;
%             explog(i).audioNameShort = audio(ID).audioNameShort;
%             
%             
%             audioname = [pwd audio(ID).name(2:end)];
%             % Play the sound and send trigger for 1s
%             [response, loadtime, wholetime] = only_audio_display_EEG(p,audioname,device,ID,1000);
%             
%             explog(i).eventStartTime = t + loadtime;
%             explog(i).response = response;
%             explog(i).loadtime = loadtime;
%             explog(i).wholetime = wholetime;
%             
%             Screen('DrawLines',p.whandle,p.fixcross,p.fixwidth,p.fixcolor);
%             Screen('Flip', p.whandle);
%             % Each event is 3s
%             WaitSecs(3 - wholetime)
%             
%             i = i + 1;
%             
%             % Play the oddball if it is the time
%             
%             
%             if play_oddball(n) == 1
%                 audioname = [pwd oddball(2:end)];
%                 
%                 explog(i).ID = 81;
%                 explog(i).name = oddball;
%                 explog(i).audioNameShort = 'oddball';
%                 
%                 [response, loadtime, wholetime] = only_audio_display_EEG(p,audioname,device,81,1000);
%                 explog(i).eventStartTime = t + loadtime;
%                 
%                 tic;
%                 while toc < 3 - wholetime
%                     
%                     Screen('DrawLines',p.whandle,p.fixcross,p.fixwidth,p.fixcolor);
%                     Screen('Flip', p.whandle);
%                     % If button press, send trigger for 50 ms using 8th bit
%                     if KbCheck(-1)
%                         send_Pulse(device, 128, 50);
%                     end
%                 end
%                 explog(i).response = response;
%                 explog(i).loadtime = loadtime;
%                 explog(i).wholetime = wholetime;
%                 
%                 i = i + 1;
%             end
%             
%             
%             
%         end
%         
%         % Send trigger at the end of each run, duration is 10 ms
%         send_Pulse(device, runEnd,10);
%         
%         % Calculate run accuracy
%         resp_ind = find([explog.response] == 1);
%         run.accuracy = sum([explog(resp_ind).ID] == 81)/exp.numOdd;
%         
%         run.explog = explog;
%         
%         exp.run(r) = run;
%         
%         % Save exp and run information
%         save(save_file_name, 'exp', 'run');
%         
%     end
%     
%     
%     % Participants can continue or end
%     for r = 13:15
%         
%         % Instruction
%         str = ['You have finished ' int2str(r-1) ' runs. If you are willing to continue for a next run, you can press space'];
%         Screen('DrawText', p.whandle, str, p.xCenter-1000, p.yCenter-300, [0 0 0]);
%         
%         str = 'button to have another run. If not, you can press escape button to end the experiment.';
%         Screen('DrawText', p.whandle, str, p.xCenter-1000, p.yCenter-200, [0 0 0]);
%         
%         str = 'We do not require you to do more than 12 runs. But doing more will benefit us, and you will';
%         Screen('DrawText', p.whandle, str, p.xCenter-1000, p.yCenter, [0 0 0]);
%         
%         str = 'gain more compensations.';
%         Screen('DrawText', p.whandle, str, p.xCenter-1000, p.yCenter+100, [0 0 0]);
%         Screen('Flip', p.whandle);
%         
%         % Wait for button press
%         while 1
%             [~, keyCode, ~] = KbWait([], 2);
%             if keyCode(p.escapeKey) || keyCode(p.spaceKey)
%                 break;
%             end
%         end
%         
%         
%         % Stop if eascape button
%         if keyCode(p.escapeKey)
%             break;
%             
%         % Continue if space button
%         elseif keyCode(p.spaceKey)
%             
%             WaitSecs(2);
%             % Start master clock
%             run.startTime = GetSecs; %This becomes time zero
%             
%             % Start run
%             trials = randperm(80); % randomize the video diplay order
%             
%             % Send trigger at the begining of each run, duration is 10 ms
%             send_Pulse(device, runStart, 10);
%             
%             i = 1; %used for mark each trial event
%             
%             % Generate random sequence for display noise audios
%             play_oddball = [ones(1,10) zeros(1,70)];
%             play_oddball = play_oddball(randperm(80));
%             clear explog
%             for n = 1:80
%                 
%                 % Play stimuli
%                 t = GetSecs-run.startTime;
%                 
%                 ID = trials(n);
%                 
%                 explog(i).eventStartTime = t;
%                 explog(i).eventLabel = getLabel(videoID);
%                 explog(i).ID = ID;
%                 explog(i).response = NaN;
%                 explog(i).name = audio(ID).name;
%                 
%                 
%                 audioname = [pwd audio(ID).name(2:end)];
%                 % Play the sound and send trigger for 1s
%                 [response, loadtime, wholetime] = only_audio_display_EEG(p,audioname,device,videoID,1000);
%                 
%                 explog(i).eventStartTime = t + loadtime;
%                 explog(i).response = response;
%                 explog(i).loadtime = loadtime;
%                 explog(i).wholetime = wholetime;
%                 
%                 Screen('DrawLines',p.whandle,p.fixcross,p.fixwidth,p.fixcolor);
%                 Screen('Flip', p.whandle);
%                 % Each event is 3s
%                 WaitSecs(3 - wholetime)
%                 
%                 i = i + 1;
%                 
%                 % Play the oddball if it is the time
%                 
%                 
%                 if play_oddball(n) == 1
%                     audioname = [pwd oddball_sound(2:end)];
%                     explog(i).name = oddball;
%                     explog(i).audioNameShort = 'oddball';
%                     
%                     [response, loadtime, wholetime] = only_audio_display_EEG(p,audioname,device,videoID,1000);
%                     explog(i).eventStartTime = t + loadtime;
%                     
%                     tic;
%                     while toc < 3 - wholetime
%                         
%                         Screen('DrawLines',p.whandle,p.fixcross,p.fixwidth,p.fixcolor);
%                         Screen('Flip', p.whandle);
%                         % If button press, send trigger for 50 ms using 8th bit
%                         if KbCheck(-1)
%                             send_Pulse(device, 128, 50);
%                         end
%                     end
%                     explog(i).response = response;
%                     explog(i).loadtime = loadtime;
%                     explog(i).wholetime = wholetime;
%                     
%                     i = i + 1;
%                 end
%                 
%                 
%                 
%             end
%             
%             % Send trigger at the end of each run, duration is 10 ms
%             send_Pulse(device, runEnd,10);
%             
%             % Calculate run accuracy
%             resp_ind = find([explog.response] == 1);
%             run.accuracy = sum([explog(resp_ind).ID] == 81)/exp.numOdd;
%             
%             run.explog = explog;
%             
%             exp.run(r) = run;
%             
%             % Save exp and run information
%             save(save_file_name, 'exp', 'run');
%         end
%         
%         
%     end
%     % Show cursor again:
%     ShowCursor(p.whandle);
%     
%     % Close screens.
%     sca;
    
% catch
%     % Save exp and run information
%     save(save_file_name, 'exp', 'run');
%     % Error handling: Close all p.whandledows and movies, release all ressources.
%     sca;
%     rethrow(lasterror);
    
% end

