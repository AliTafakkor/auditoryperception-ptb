sca;
clear;clc;

addpath('utils');

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
p.pahandle = PsychPortAudio('Open', getSoundCardID(), [], 0, 48000, 2);
%PsychPortAudio('Volume', p.pahandle, 0.03);


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
save_path = fullfile('..', 'results', 'fMRI', exp.subjID);
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
    p.xCenter = floor(p.wRect(3)/2);
    p.yCenter = floor(p.wRect(4)/2);
    p.hpad = p.wRect(3)*0.05;
    p.vpad = p.wRect(4)*0.05;
    p.margin = p.wRect(4)*0.025;
    p.xCenter = p.wRect(3)/2;
    p.yCenter = p.wRect(4)/2;
    fixlinelength = 10;
    p.fixcross = [p.xCenter-fixlinelength p.xCenter+fixlinelength p.xCenter p.xCenter; p.yCenter p.yCenter p.yCenter-fixlinelength p.yCenter+fixlinelength];
    p.fixwidth = 2.5;
    p.fixcolor = [1 1 1];
    
    
    
    % Load optseq sequences (each paradigm file is a run)
    parfilename = fullfile('.', 'optseq', sprintf('perception-%3.3d.par',exp.runNumber));
    optseq_original = read_optseq_paradigm(parfilename);
    
    % Assign random (but unique) sounds to event categories
    animals = 1:20;
    people = 21:40;
    objects = 41:60;
    scenes = 61:80;
    
    
    rng('shuffle') ;
    optseq_original.audioID = zeros(size(optseq_original.eventID));
    optseq_original.audioID(optseq_original.eventID==1) = animals(randperm(20,20));
    optseq_original.audioID(optseq_original.eventID==2) = people(randperm(20,20));
    optseq_original.audioID(optseq_original.eventID==3) = objects(randperm(20,20));
    optseq_original.audioID(optseq_original.eventID==4) = scenes(randperm(20,20));
    optseq_original.audioID(optseq_original.eventID==5) = 81; % oddball
    
    % Add NULL in optseq to each trial
    optseq.ntp = optseq_original.ntp / 2;
    for k = 1:optseq_original.ntp / 2 
        optseq.time(k) = optseq_original.time(2*k - 1);
        optseq.eventID(k) = optseq_original.eventID(2*k - 1);
        optseq.eventduration(k) = optseq_original.eventduration(2*k - 1) + optseq_original.eventduration(2*k);
        optseq.eventlabel(k) = optseq_original.eventlabel(2*k - 1);
        optseq.audioID(k) = optseq_original.audioID(2*k - 1);
    end
    

    exp.optseq = optseq;
    
    % Instruction text
    str = 'fMRI Perception Task';
    drawAlignedText(p, str, p.yCenter, 0, 'c', 'c')
    %Screen('DrawText', p.whandle, str, p.xCenter-400, p.yCenter-50, [0 0 0]);
    Screen('Flip', p.whandle);
    
    % Wait for fMRI trigger
    wait_fmritrigger;
    
    % Start master clock
    start = GetSecs; %This becomes time zero
    disp('fMRI trigger received. Run starting.');
    
    
    %% start run
    
    for i = 1:optseq.ntp %trial number
        
        explog(i).eventID = optseq.audioID(i);
        explog(i).eventLabel = char(optseq.eventlabel(i));
        explog(i).audioID = optseq.audioID(i);
        explog(i).response = NaN;
        

        switch optseq.eventID(i) %1-4 for categories, 5 for oddball
                
            case 5 % oddball
                
                audioname = audio(81).name;
                explog(i).audioName = audioname;
                explog(i).audioNameShort = 'oddball';
                explog(i).eventDuration = optseq.eventduration(i);
                
                event_start_time = optseq.time(i) + 1;
                explog(i).optseqStartTime = event_start_time;
                [response, onset] = only_audio_display_fMRI(p, audioname, start, event_start_time);
                %[response, onset] = video_audio_display(p,moviename,audioname,start, event_start_time);
                
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
     
            otherwise % stimuli
                
                audioname = audio(optseq.audioID(i)).name;
                explog(i).audioName = audioname;
                explog(i).eventDuration = optseq.eventduration(i);
                
                event_start_time = optseq.time(i) + 1;
                explog(i).optseqStartTime = event_start_time;
                [response, onset] = only_audio_display_fMRI(p, audioname, start, event_start_time);

                explog(i).eventOnset = onset;
                explog(i).response = response;
                
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

