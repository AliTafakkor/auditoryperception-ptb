function sound_play(pahandle)

PsychPortAudio('Start', pahandle, 1, 0, 1);
%PsychPortAudio('DeleteBuffer', 0, 1);
% % Read WAV file from filesystem:
% [y, freq] = audioread(soundfilename);
% %[y, freq] = psychwavread(wavfilename);
% wavedata = y';
% nrchannels = size(wavedata,1); % Number of rows == number of channels.
% 
% % Make sure we have always 2 channels stereo output.
% % Why? Because some low-end and embedded soundcards
% % only support 2 channels, not 1 channel, and we want
% % to be robust in our demos.
% if nrchannels < 2
%     wavedata = [wavedata ; wavedata];
%     nrchannels = 2;
% end
% 
% device = [];
% 
% 
% % Perform basic initialization of the sound driver:
% InitializePsychSound;
% 
% % Open the  audio device, with default mode [] (==Only playback),
% % and a required latencyclass of zero 0 == no low-latency mode, as well as
% % a frequency of freq and nrchannels sound channels.
% % This returns a handle to the audio device:
% try
%     % Try with the 'freq'uency we wanted:
%     pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
% catch
%     % Failed. Retry with default frequency as suggested by device:
%     fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', freq);
%     fprintf('Sound may sound a bit out of tune, ...\n\n');
%     
%     psychlasterror('reset');
%     pahandle = PsychPortAudio('Open', device, [], 0, [], nrchannels);
% end
% 
% % Fill the audio playback buffer with the audio data 'wavedata':
% PsychPortAudio('FillBuffer', pahandle, wavedata);
% 
% % Start audio playback for 'repetitions' repetitions of the sound data,
% % start it immediately (0) and wait for the playback to start, return onset
% % timestamp.
% t1 = PsychPortAudio('Start', pahandle, 1, 0, 1);
% 
% % Wait for release of all keys on keyboard:
% %KbReleaseWait;
% 
% 
% % Stop playback:
% %PsychPortAudio('Stop', pahandle);
% 
% % Close the audio device:
% %PsychPortAudio('Close', pahandle);

end
