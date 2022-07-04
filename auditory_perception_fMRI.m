sca;
clear;clc;

addpath('Functions');

% Skip synchronization checks
Screen('Preference', 'SkipSyncTests', 1);
AssertOpenGL;                                   

% Initialize with unified keynames and normalized colorspace:
PsychDefaultSetup(2);

dummy=GetSecs;  % Force GetSecs and WaitSecs into memory to avoid latency later on:
WaitSecs(0.1);

% Set parameters
p.text_size = 100;
p.text_font = 'Arial';

% Set experimental infotmation
experiment_info;

% Get subject name
exp.subjID = input('Name of subject: ','s');
exp.run = input('Run number: ');


% Setup key mapping:
p.escapeKey = KbName('ESCAPE');
p.spaceKey = KbName('SPACE');
p.triggerKey = KbName('t');
p.pressKey = KbName('y');

% Load audio device
InitializePsychSound;
p.pahandle = PsychPortAudio('Open', [], [], 0, 48000, 2);

% Load silent audio to buffer
sound_load(fullfile('.', 'stimuli', 'silence.mp3', p.pahandle);
sound_play(p.pahandle);

% Load audio files
folder = '.\Stimuli\sound';
categories = ["animals", "objects", "scenes", "people"];

ite = 1;
for c = 1:length(categories)
    
    category = categories(c);
    moviefiles = dir(fullfile(folder, category, '*.mp3'));
    
    for i=1:size(moviefiles,1)
        audio(ite).videoNameShort = moviefiles(i).name(1:end-4);
        moviefiles(i).name = char(fullfile(folder, category, moviefiles(i).name));
        audio(ite).videoID = ite;
        audio(ite).videoName = moviefiles(i).name;
        
        ite = ite + 1;
        
    end
    
end

% Load oddball
oddball = '.\Stimuli\oddball\noise.mp3';

% Save video information
audio(81).videoID = 81;
audio(81).videoName = oddball;
audio(81).videoNameShort = 'oddball';
exp.stim = audio;

exp.date = nowstring;
save_path = ['.\Results\' exp.subjID];
mkdir(save_path);
save_file_name = [save_path filesep exp.name '_auditory_perception_task_fMRI_run_' int2str(exp.run) '_' exp.subjID '_' exp.date '.mat'];



try
    
    % Open onscreen window with gray background:
    screenID = max(Screen('Screens'));
    PsychImaging('PrepareConfiguration');
    
    [p.whandle, p.wRect] = Screen('OpenWindow', screenID, [127 127 127]);
    Screen('TextSize', p.whandle, p.text_size);
    %Screen('Blendfunction', p.whandle, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    HideCursor(p.whandle);
    
    % Paramters for fixation cross
    p.xCenter = p.wRect(3)/2;
    p.yCenter = p.wRect(4)/2;
    fixlinelength = 10;
    p.fixcross = [p.xCenter-fixlinelength p.xCenter+fixlinelength p.xCenter p.xCenter; p.yCenter p.yCenter p.yCenter-fixlinelength p.yCenter+fixlinelength];
    p.fixwidth = 2.5;
    p.fixcolor = [1 1 1];
    
    
    run.runNumber = exp.run; 
    
    % Load optseq sequences (each paradigm file is a run)
    parfilename = fullfile('.\optseq\visual_imagery\',['visual-' sprintf('%3.3d',run.runNumber) '.par']);
    optseq = read_optseq_paradigm(parfilename);
    
    % Assign random (but unique) videos to event categories
    animals = [1:20];
    objects = [21:40];
    scenes = [41:60];
    people = [61:80];
    
    %rng('shuffle') ;
    optseq.videoID = zeros(size(optseq.eventID));
    optseq.videoID(optseq.eventID==1) = animals(randperm(20,20));
    optseq.videoID(optseq.eventID==2) = objects(randperm(20,20));
    optseq.videoID(optseq.eventID==3) = scenes(randperm(20,20));
    optseq.videoID(optseq.eventID==4) = people(randperm(20,20));
    optseq.videoID(optseq.eventID==0) = 0; % null
    optseq.videoID(optseq.eventID==5) = 81; % oddball
    
    
    run.optseq = optseq;
    
    % Instruction text
    str = 'Visual Imagery Task';
    Screen('DrawText', p.whandle, str, p.xCenter-400, p.yCenter-50, [0 0 0]);
    Screen('Flip', p.whandle);
    
    % Wait for fMRI trigger
    wait_fmritrigger;
    
    % start master clock
    run.startTime = GetSecs; %This becomes time zero
    disp('fMRI trigger received. Run starting.');
    
    
    %% start run
    
    for i = 1:optseq.ntp %trial number
        
        t = GetSecs-run.startTime;
        
        explog(i).eventStartTime = t;
        explog(i).eventID = optseq.eventID(i);
        explog(i).eventLabel = char(optseq.eventlabel(i));
        explog(i).videoID = optseq.videoID(i);
        explog(i).response = NaN;
        
%         [keyIsDown, ~, keyCode] = KbCheck(-1);
%         if (keyIsDown==1 && keyCode(escapeKey))
%             save(save_file_name, 'exp','run');
%             error('quit')
%         end
        
        switch optseq.eventID(i) % 0 for null, 1-4 for categories, 5 for oddball
            
            case 0 % NULL
                
                Screen('DrawLines',p.whandle,p.fixcross,p.fixwidth,p.fixcolor);
                Screen('Flip', p.whandle);
                nulltime = optseq.eventduration(i);
                WaitSecs(nulltime)
                
            case 5 % oddball
                
                
                audioname = [pwd oddball_sound(2:end)];
                explog(i).videoName = oddball;
                explog(i).videoNameShort = 'oddball';

                [response, loadtime, wholetime] = only_audio_display(p,audioname);
                explog(i).eventStartTime = t + loadtime;
                
                tic;
                while toc < 3 - wholetime
                    
                    Screen('DrawLines',p.whandle,p.fixcross,p.fixwidth,p.fixcolor);
                    Screen('Flip', p.whandle);
                    if response ~= 1
                        response = KbCheck(-1);
                    end
                end
                explog(i).response = response;
                explog(i).loadtime = loadtime;
                explog(i).wholetime = wholetime;
                
                
                
            otherwise % videos
                
                explog(i).videoName = videos(optseq.videoID(i)).videoName;
                explog(i).videoNameShort = videos(optseq.videoID(i)).videoNameShort;
                
                audioname = [pwd audio(optseq.videoID(i)).videoName(2:end)];
                [response, loadtime, wholetime] = only_audio_display(p,audioname);
                
                explog(i).eventStartTime = t + loadtime;
                explog(i).response = response;
                explog(i).loadtime = loadtime;
                explog(i).wholetime = wholetime;

                
                Screen('DrawLines',p.whandle,p.fixcross,p.fixwidth,p.fixcolor);
                Screen('Flip', p.whandle);
                WaitSecs(3 - wholetime);
                
                
                
        end
    end
    
    run.accuracy = sum([explog.response] == 1)/20;
    run.explog = explog;
    %exp.run(trial) = run;
    save(save_file_name, 'exp', 'run');
    
    
    % Show cursor again:
    ShowCursor(p.whandle);
    
    PsychPortAudio('Close', p.pahandle);
    % Close screens.
    sca;
    
catch 
    % Error handling: Close all p.whandledows and movies, release all ressources.
    sca;
    rethrow(lasterror); 
end

