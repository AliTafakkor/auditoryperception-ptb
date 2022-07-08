% Get subjectID
subjectID = input('Enter subject ID: ', 's');

% Get session type 
familiarization = input('Session include familiarization (y/n): ', 's');

% Run session
if (strcmp(familiarization, 'y'))
    fprintf('starting familiarization section:')
    stimuli_familiarization;
    fprintf('starting recognition task:')
    stimuli_recognition;
    fprintf('starting imageability section:')
    stimuli_imageability;
    fprintf('End of the session.')
elseif (strcmp(familiarization, 'n'))
    fprintf('starting recognition task:')
    stimuli_recognition;
    fprintf('starting imageability section:')
    stimuli_imageability;
    fprintf('End of the session.')
else
    error('Enter valid response (y or n)!')
end