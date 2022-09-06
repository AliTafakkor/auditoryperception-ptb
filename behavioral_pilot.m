sca; clear; clc;

% Get subjectID
subjectID = input('Enter subject ID: ', 's');
Screen('Preference', 'SkipSyncTests', 1);

% Get session type 
familiarization = input('Session include familiarization (y/n): ', 's');

% Run session
if (strcmp(familiarization, 'y'))
    fprintf('starting familiarization section: \n')
    stimuli_familiarization;
    fprintf('starting recognition task: \n')
    stimuli_recognition;
    fprintf('starting imageability section: \n')
    stimuli_imageability;
    fprintf('End of the session.\n')
elseif (strcmp(familiarization, 'n'))
    fprintf('starting recognition task: \n')
    stimuli_recognition;
    fprintf('starting imageability section: \n')
    stimuli_imageability;
    fprintf('End of the session.\n')
else
    error('Enter valid response (y or n)!')
end