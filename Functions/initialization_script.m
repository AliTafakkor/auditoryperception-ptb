Screen('Preference', 'SkipSyncTests', 1); 

% initialization script

%clear previous variables
clc;
Screen('CloseAll')

%get subject name
p.subjID = input('Name of subject: ','s');

%initialize button responses
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');

%check Java
warning off
PsychJavaTrouble;
warning on

%initialize functions
dummy=GetSecs;  % Force GetSecs and WaitSecs into memory to avoid latency later on:
WaitSecs(0.1);

%OpenGL support
AssertOpenGL;

%set screen
screens=Screen('Screens');
screenNumber=max(screens);

% Open a double buffered window and draw a white (or other) background to front and back buffers
[p.whandle, p.wp.wRectt]=Screen('OpenWindow',screenNumber, 0,[],32,2); %fullsize
white=WhiteIndex(screenNumber); % returns as default the mean white value of screen
p.background_color = 128; %128;x
Screen('Fillp.wRectt',p.whandle,p.background_color ); %black screen
Screen('Flip', p.whandle);
 
% set Text properties (all Screen functions must be called after screen)
Screen('TextSize', p.whandle, p.text_size);
Screen('TextFont', p.whandle, p.text_font);
Screen('TextStyle',p.whandle,32);

% set priority - also set after Screen init
priorityLevel=MaxPriority(p.whandle);
Priority(priorityLevel);

%center of screen
p.xCenter = p.wp.wRectt(3)/2;
p.yCenter = p.wp.wRectt(4)/2;

%screen refresh rate
p.refreshRate= Screen('GetFlipInterval', p.whandle);
p.flashDuration=80*p.refreshRate;




