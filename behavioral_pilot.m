% Get subjectID
subjectID = input('Enter subject ID: ', 's');

% Get session type 
familiarization = input('Session include familiarization (y/n): ', 's');

% Run session
if (strcmp(familiarization, 'y'))
    
    stimuli_familiarization;
    stimuli_recognition;
    stimuli_imageability;
elseif (strcmp(familiarization, 'n'))
    stimuli_recognition;
    stimuli_imageability;
else
    error('Enter valid response (y or n)!')
end