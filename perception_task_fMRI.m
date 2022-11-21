sca;
clear;clc;

addpath('Functions');

% Skip synchronization checks
Screen('Preference', 'SkipSyncTests', 1);

% Initialize with unified keynames and normalized colorspace:
PsychDefaultSetup(2);

% Force GetSecs and WaitSecs into memory to avoid latency later on:
dummy=GetSecs;  
WaitSecs(0.1);

% Set parameters
p.text_size = 100;
p.text_font = 'Arial';

% Set experimental infotmation
experiment_info;

% Get subject name
exp.subjID = input('Name of subject: ','s');
exp.runNumber = input('Run number: ');


% Setup key mapping:
p.escapeKey = KbName('q');
p.spaceKey = KbName('SPACE');
p.triggerKey = KbName('t');
p.pressKey = KbName('b');

% Load audio device
InitializePsychSound;
p.pahandle = PsychPortAudio('Open', [], [], 0, 48000, 2);


% Load silent audio to buffer
sound_load(fullfile('.', 'stimuli', 'silence.wav'), p.pahandle);
sound_play(p.pahandle);


% Load audio files
folder = fullfile('.', 'stimuli');
categories = ["animals", "people", "objects", "scenes"];

ite = 1;
for c = 1:length(categories)
    category = categories(c);
    files = dir(fullfile(folder, category, '*.wav'));
    for i=1:size(files,1)
        audio(ite).audioNameShort = files(i).name(1:end-4);
        files(i).name = char(fullfile(folder, category, files(i).name));
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

% Save experiment information
exp.date = nowstring;
save_path = fullfile('..', 'results', exp.subjID);
mkdir(save_path);
save_file_name = [save_path filesep exp.name '_auditory__perception_task_fMRI_run_' exp.subjID '_' exp.date '.mat'];
exp.task = 'Perception';

rng('default');
rng('shuffle');

try
    
    % Open onscreen window with gray background:
    screenID = max(Screen('Screens'));
    %PsychImaging('PrepareConfiguration');
    
    [p.whandle, p.wRect] = Screen('OpenWindow', screenID, [127 127 127]);
    Screen('TextSize', p.whandle, p.text_size);
    Screen('Blendfunction', p.whandle, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    HideCursor(p.whandle);
    
    % Paramters for fixation cross
    p.xCenter = p.wRect(3)/2;
    p.yCenter = p.wRect(4)/2;
    fixlinelength = 10;
    p.fixcross = [p.xCenter-fixlinelength p.xCenter+fixlinelength p.xCenter p.xCenter; p.yCenter p.yCenter p.yCenter-fixlinelength p.yCenter+fixlinelength];
    p.fixwidth = 2.5;
    p.fixcolor = [1 1 1];
    
    
    
    % Load optseq sequences (each paradigm file is a run)
    parfilename = fullfile('./optseq/perception',['perception-' sprintf('%3.3d',exp.runNumber) '.par']);
    optseq_original = read_optseq_paradigm(parfilename);
    
    % Assign random (but unique) videos to event categories
    animals = [1:20];
    people = [21:40];
    objects = [41:60];
    scenes = [61:80];
    
    
    %rng('shuffle') ;
    optseq_original.videoID = zeros(size(optseq_original.eventID));
    optseq_original.videoID(optseq_original.eventID==1) = animals(randperm(20,20));
    optseq_original.videoID(optseq_original.eventID==2) = people(randperm(20,20));
    optseq_original.videoID(optseq_original.eventID==3) = objects(randperm(20,20));
    optseq_original.videoID(optseq_original.eventID==4) = scenes(randperm(20,20));
    optseq_original.videoID(optseq_original.eventID==5) = 81; % oddball
    
    % Add NULL in optseq to each trial
    optseq.ntp = optseq_original.ntp / 2;
    for k = 1:optseq_original.ntp / 2 
        optseq.time(k) = optseq_original.time(2*k - 1);
        optseq.eventID(k) = optseq_original.eventID(2*k - 1);
        optseq.eventduration(k) = optseq_original.eventduration(2*k - 1) + optseq_original.eventduration(2*k);
        optseq.eventlabel(k) = optseq_original.eventlabel(2*k - 1);
        optseq.videoID(k) = optseq_original.videoID(2*k - 1);
    end
    

    exp.optseq = optseq;
    
    % Instruction text
    str = 'Video Detection Task';
    Screen('DrawText', p.whandle, str, p.xCenter-400, p.yCenter-50, [0 0 0]);
    Screen('Flip', p.whandle);
    
    % Wait for fMRI trigger
    wait_fmritrigger;
    
    % Start master clock
    start = GetSecs; %This becomes time zero
    disp('fMRI trigger received. Run starting.');
    
    
    %% start run
    
    for i = 1:optseq.ntp %trial number
        
        explog(i).eventID = optseq.eventID(i);
        explog(i).eventLabel = char(optseq.eventlabel(i));
        explog(i).videoID = optseq.videoID(i);
        explog(i).response = NaN;
        

        switch optseq.eventID(i) %1-4 for categories, 5 for oddball
                
            case 5 % oddball
                
                moviename = [pwd oddball(2:end)];
                audioname = [pwd oddball_sound(2:end)];
                explog(i).videoName = oddball;
                explog(i).videoNameShort = 'oddball';
                explog(i).eventDuration = optseq.eventduration(i);
                
                event_start_time = optseq.time(i) + 1;
                explog(i).optseqStartTime = event_start_time;
                [response, onset] = video_audio_display(p,moviename,audioname,start, event_start_time);
                
                explog(i).eventOnset = onset;
                explog(i).response = response;
                
                
%                 tic;
%                 while toc < explog(i).eventduration - 1
%                     
%                     Screen('DrawLines',p.whandle,p.fixcross,p.fixwidth,p.fixcolor);
%                     Screen('Flip', p.whandle);
%                     if response ~= 1
%                         response = KbCheck(-1);
%                     end
%                 end
     
            otherwise % videos
                
                explog(i).videoName = videos(optseq.videoID(i)).videoName;
                explog(i).videoNameShort = videos(optseq.videoID(i)).videoNameShort;
                explog(i).eventDuration = optseq.eventduration(i);
                
                audioname = [pwd audio(optseq.videoID(i)).videoName(2:end)];
                moviename = [pwd explog(i).videoName(2:end)];
                
                event_start_time = optseq.time(i) + 1;
                explog(i).optseqStartTime = event_start_time;
                [response, onset] = video_audio_display(p,moviename,audioname,start, event_start_time);

                
                explog(i).eventOnset = onset;
                explog(i).response = response;


                
%                 Screen('DrawLines',p.whandle,p.fixcross,p.fixwidth,p.fixcolor);
%                 Screen('Flip', p.whandle);
%                 WaitSecs(explog(i).eventduration - 1);
                

        end
    end
    
    exp.accuracy = sum([explog.response] == 1)/10;
    exp.explog = explog;
    save(save_file_name, 'exp');
    
    WaitSecs(13);
    
    % Show cursor again:
    ShowCursor(p.whandle);
    
    % Close audio device
    PsychPortAudio('Close', p.pahandle);
    
    % Close screens.
    sca;
    
catch 
    % Error handling: Close all p.whandledows and movies, release all ressources.
    sca;
    % Close audio device
    PsychPortAudio('Close', p.pahandle);
    rethrow(lasterror); 
end

