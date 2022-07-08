sca; clearvars -except subjectID;

% Add path to utility functions
addpath('utils');

% Skip synchronization checks (to test)
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
exp.numStim = 81;
exp.numCategory = 4;
exp.timPerStim = 1;

% Get subject ID
%subjectID = input('Enter subject ID: ', 's');
exp.subjID = subjectID;

% Setup key mapping:
p.nextKey = KbName('RIGHTARROW');
p.previousKey = KbName('LEFTARROW');
p.repeatKey = KbName('DOWNARROW');
p.escapeKey = KbName('ESCAPE');
p.spaceKey = KbName('SPACE');
p.pressKey = p.spaceKey;

% Load audio files and descriptions

stimuli_folder = fullfile('.', 'stimuli');
categories = ["animals", "objects", "people", "scenes"];
ite = 1;

fileID = fopen(fullfile(stimuli_folder,'description.txt'),'r');
for category = categories
    files = dir(fullfile(stimuli_folder, category, '*.mp3'));
    for i=1:size(files,1)
        audio(ite).audioNameShort = files(i).name(1:end-4);
        files(i).name = char(fullfile(stimuli_folder, category, files(i).name));
        audio(ite).ID = ite;
        audio(ite).name = files(i).name;
        audio(ite).description = fgetl(fileID);

        ite = ite + 1; 
    end
end
fclose(fileID);


% Load oddball
oddball = fullfile('.', 'stimuli', 'noise.wav');

% Save audio information
audio(81).ID = 81;
audio(81).name = oddball;
audio(81).audioNameShort = 'oddball';
audio(81).description = 'Noise (target)';
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

try    
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
    str = 'In this section, you will hear a series of sounds and see a short decription along side them.';
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
    
    % Familiarization
    rng('shuffle');
    randind = randperm(exp.numStim);
    n = 1;
    while (true)
        if (n<82)
            ID = randind(n);
            audioname = [pwd audio(ID).name(2:end)];
            description = audio(ID).description;
    
            % Load and Play the sound
            sound_load(audioname,p.pahandle);
            sound_play(p.pahandle);
            
            % Show description
            drawAlignedText(p, description, p.wRect(4)/2, -2, 'c', 'c')
            str = sprintf('%d/%d', n, exp.numStim);
            drawAlignedText(p, str, 0, 0, 't', 'l')
            Screen('Flip', p.whandle);
        end

        % Control buttons
        WaitSecs(1); 
        KbWait([], 2);
        [keyIsDown, ~, keyCode] = KbCheck(-1);
        if (keyIsDown==1 && keyCode(p.nextKey))
            if (n<82)
                n = n + 1;
                continue;
            else
                break;
            end
        elseif (keyIsDown==1 && keyCode(p.previousKey))
            if (n>1)
                n = n - 1;
                continue;
            end
        elseif (keyIsDown==1 && keyCode(p.repeatKey))
            continue;
        elseif (keyIsDown==1 && keyCode(p.escapeKey))
            break;
        end
    end

    % End screen
    str = 'Great! you are now familiarized with the sounds.';
    drawAlignedText(p, str, p.wRect(4)/2, -2, 'c', 'c')
    str = 'Press any key to exit.';
    drawAlignedText(p, str, p.wRect(4)/2, 0, 'c', 'c')
    Screen('Flip', p.whandle);

    KbWait([], 2);

    % Save exp and run information
    save(save_file_name, 'exp');

    % Close audio port
    PsychPortAudio('Close', p.pahandle);

    % Show cursor again:
    ShowCursor(p.whandle);
    
    % Close screens.
    sca;
    
catch

    % Save exp and run information
    save(save_file_name, 'exp');
    % Error handling: Close all p.whandledows and audioport, release all ressources.
    PsychPortAudio('Close', p.pahandle);
    sca;
    rethrow(lasterror);  

end

