sca; clear; clc;

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
exp.name = 'Stimuli_Recognition';
exp.numStim = 80;
exp.numRuns = 2;
exp.numCategory = 4;
exp.timPerStim = 1;
exp.validRespTime = 2;
exp.ITI = 1;


% Get subject name
exp.subjID = input('Name of subject: ', 's');

% Setup key mapping:
p.catKey1 = KbName('1!');
p.catKey2 = KbName('2@');
p.catKey3 = KbName('3#');
p.catKey4 = KbName('4$');
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
p.pahandle = PsychPortAudio('Open', [], [], 0, 48000, 2);

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

    str = 'CNAI lab!';
    drawAlignedText(p, str, p.wRect(4), -3, 'c', 'c')

    Screen('Flip', p.whandle);

    KbWait([], 2);

    % Instructions screen
    str = 'In this section, You will hear a series of sounds and be asked to categorize them.';
    drawAlignedText(p, str, 0, 1, 't', 'l')
    
    str = 'After hearing each sound you will have a short time to identify its category.';
    drawAlignedText(p, str, 0, 2, 't', 'l')

    str = 'You should indicate the category by pressing numbers 1 to 4 corresponding to:';
    drawAlignedText(p, str, 0, 4, 't', 'l')

    str = '1: Animal';
    drawAlignedText(p, str, 0, 6, 't', 'l')
    str = '2: Object';
    drawAlignedText(p, str, 10, 6, 't', 'l')
    str = '3: People';
    drawAlignedText(p, str, 0, 7, 't', 'l')
    str = '4: Scene';
    drawAlignedText(p, str, 0, 9, 't', 'l')

    str = sprintf('You will complete %d runs, you can rest between runs.', exp.numRuns);
    drawAlignedText(p, str, 0, 12, 't', 'l')
    str = 'Press any key to start.';
    drawAlignedText(p, str, 0, 13, 't', 'l')

    Screen('Flip', p.whandle);

    % Wait for button press
    KbWait([], 2);
    
    exp.runs = {};
    quitFlag = false;
    % Imageability task
    for r = 1:exp.numRuns
        randind = randperm(exp.numStim);

        run.runNumber = r;
        run.stimOrder = randind;
        run.responses = NaN(1,exp.numStim);
        run.trialTimes = NaN(1,exp.numStim);

        for n = 1:exp.numStim
            % Inter Trial Interval
            WaitSecs(exp.ITI);

            ID = randind(n);
            audioname = [pwd audio(ID).name(2:end)];
    
            tic;

            % Load and Play the sound
            sound_load(audioname,p.pahandle);
            sound_play(p.pahandle);
            
            % Show guide
            str = 'What category this sound belongs to?';
            drawAlignedText(p, str, 0, 4, 'c', 'c')

            str = '1: Animal';
            drawAlignedText(p, str, 0, 6, 't', 'c')
            str = '2: Object';
            drawAlignedText(p, str, 10, 6, 't', 'c')
            str = '3: People';
            drawAlignedText(p, str, 0, 7, 't', 'c')
            str = '4: Scene';
            drawAlignedText(p, str, 0, 9, 't', 'c')
            
            Screen('Flip', p.whandle);
            
            % Control buttons
            while (toc < exp.validRespTime)
                [keyIsDown, ~, keyCode] = KbCheck(-1);
                if (keyIsDown==1 && keyCode(p.catKey1))
                    run.responses(n) = 1;
                elseif (keyIsDown==1 && keyCode(p.catKey2))
                    run.responses(n) = 2;
                elseif (keyIsDown==1 && keyCode(p.catKey3))
                    run.responses(n) = 3;
                elseif (keyIsDown==1 && keyCode(p.catKey4))
                    run.responses(n) = 4;
                elseif (keyIsDown==1 && keyCode(p.escapeKey))
                    quitFlag = true;
                end
            end
            
            % Save trial time
            run.trialTimes(n) = toc;
            
            if quitFlag
                break;
            end
        end

        % Save run data in exp
        exp.runs{end+1} = run;
        
        if quitFlag
            break;
        end
        WaitSecs(5)
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

