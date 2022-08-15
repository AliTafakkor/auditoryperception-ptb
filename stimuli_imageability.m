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
exp.name = 'Stimuli_Imageability';
exp.numStim = 80;
exp.numCategory = 4;
exp.timPerStim = 1;

% Get subject ID
%subjectID = input('Enter subject ID: ', 's');
exp.subjID = subjectID;

% Setup key mapping:
p.scoreKey1 = KbName('1!');
p.scoreKey2 = KbName('2@');
p.scoreKey3 = KbName('3#');
p.scoreKey4 = KbName('4$');
p.scoreKey5 = KbName('5%');
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
    files = dir(fullfile(stimuli_folder, category, '*.wav'));
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

% Save audio information
exp.stim = audio;

exp.date = nowstring;
save_path = fullfile('..', 'results', exp.subjID);

if ~isfolder(save_path)
    mkdir(save_path);
end 

save_file_name = fullfile(save_path, sprintf('%s_%s_%s.mat', exp.name, exp.subjID, exp.date));

% Load audio device
InitializePsychSound;
p.pahandle = PsychPortAudio('Open', getSoundCardID(), [], 0, 48000, 2);

% Load silent audio to buffer
sound_load(fullfile('.', 'stimuli', 'silence.wav'), p.pahandle);
sound_play(p.pahandle);

try    
    % Open onscreen window with gray background:
    screenID = max(Screen('Screens'));
    PsychImaging('PrepareConfiguration');
    [p.whandle, p.wRect] = Screen('OpenWindow', screenID, [127 127 127]);
    % Define some usefull parameters based on screen size
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

    str = 'CNAI lab';
    drawAlignedText(p, str, p.wRect(4), -3, 'c', 'c')

    Screen('Flip', p.whandle);

    KbWait([], 2);

    % Instructions screen
    str = 'In this section, we want you to rate the imageability of sounds.';
    drawAlignedText(p, str, 0, 1, 't', 'l')
    str = 'You will hear a series of sounds and be asked about how easy is that for you to visualize what you are hearing.';
    drawAlignedText(p, str, 0, 2, 't', 'l')
    
    str = 'You hear each sound just once. ';
    drawAlignedText(p, str, 0, 3, 't', 'l')

    str = 'Then, you should give it a score from 1 to 5 indicating:';
    drawAlignedText(p, str, 0, 5, 't', 'l')

    str = '1: Very difficult to visualize';
    drawAlignedText(p, str, 0, 7, 't', 'l')
    str = '2: Difficult to visualize';
    drawAlignedText(p, str, 0, 9, 't', 'l')
    str = '3: Vaguely visualizable';
    drawAlignedText(p, str, 0, 9, 't', 'l')
    str = '4: Easy to visualize';
    drawAlignedText(p, str, 0, 10, 't', 'l')
    str = '5: Very easy to visualize';
    drawAlignedText(p, str, 0, 11, 't', 'l')

    str = 'After rating a sound, next sound will be played when you are ready.';
    drawAlignedText(p, str, 0, 13, 't', 'l')
    str = 'Press any key to start.';
    drawAlignedText(p, str, 0, 14, 't', 'l')

    Screen('Flip', p.whandle);

    % Wait for button press
    KbWait([], 2);
    
    % Imageability task
    rng('shuffle');
    randind = randperm(exp.numStim);
    exp.stimOrder = randind;
    exp.responses = NaN(1,exp.numStim);

    exitflag = 0;
    for n = 1:81
        ID = randind(n);
        audioname = [pwd audio(ID).name(2:end)];

        % Show progress
        str = sprintf('%d/%d', n, exp.numStim);
        drawAlignedText(p, str, 0, 0, 't', 'l')
        % Show guide
        str = 'Press a key when you are ready to hear the sound.';
        drawAlignedText(p, str, 0, 4, 'c', 'c')
        % Flip
        Screen('Flip', p.whandle);
        
        % Wait for key press
        WaitSecs(0.5);
        KbWait([], 2);

        % Load and Play the sound
        sound_load(audioname, p.pahandle);
        sound_play(p.pahandle);

        % Show progress
        str = sprintf('%d/%d', n, exp.numStim);
        drawAlignedText(p, str, 0, 0, 't', 'l')            
        % Show guide
        str = 'How easily did this sound bring an image to mind?';
        drawAlignedText(p, str, 0, 4, 'c', 'c')
        str = '1: Very difficult to visualize';
        drawAlignedText(p, str, 0, 6, 't', 'c')
        str = '2: Difficult to visualize';
        drawAlignedText(p, str, 0, 8, 't', 'c')
        str = '3: Vaguely visualizable';
        drawAlignedText(p, str, 0, 8, 't', 'c')
        str = '4: Easy to visualize';
        drawAlignedText(p, str, 0, 9, 't', 'c')
        str = '5: Very easy to visualize';
        drawAlignedText(p, str, 0, 10, 't', 'c')
        % Flip
        Screen('Flip', p.whandle);
        
        % Control buttons
        WaitSecs(1);
        while true
            KbWait([], 2);
            [keyIsDown, ~, keyCode] = KbCheck(-1);
            if (keyIsDown==1 && keyCode(p.scoreKey1))
                exp.responses(n) = 1;
                break;
            elseif (keyIsDown==1 && keyCode(p.scoreKey2))
                exp.responses(n) = 2;
                break;
            elseif (keyIsDown==1 && keyCode(p.scoreKey3))
                exp.responses(n) = 3;
                break;
            elseif (keyIsDown==1 && keyCode(p.scoreKey4))
                exp.responses(n) = 4;
                break;
            elseif (keyIsDown==1 && keyCode(p.scoreKey5))
                exp.responses(n) = 5;
                break;
            elseif (keyIsDown==1 && keyCode(p.escapeKey))
                exitflag = 1;
                break;
            end
        end

        if exitflag
            break;
        end
    end

    % End screen
    str = 'Great! you are done.';
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

