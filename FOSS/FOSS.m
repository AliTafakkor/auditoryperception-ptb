function [exp D] = FOSS(SID, runNum, save_root)
%-------------------------------------------------------------------------


% Experiment Name:  Face Object Scene Scrambled (FOSS) localizer
% Updated by Wilma Bainbridge: October 30, 2012
% 
% Num Conditions:   4 
% 
% Blocks Per Cond:  4 
% 
% 
% Total TRs/run:    213
% 
% Total Time:       7.1 min


%-------------------------------------------------------------------------

clc
commandwindow

% Skip synchronization checks
Screen('Preference', 'SkipSyncTests', 1);

numScreens = max(Screen('Screens'));
rand('twister',sum(100*clock));



%-------------------------------------------------------------------------
% experiment data
%-------------------------------------------------------------------------
disp('set up experiment data')

exp.name                = 'FOSS';
exp.sid                 = SID;
exp.runNum              = runNum;

exp.numConds            = 4;
exp.numBlocksPerCond    = 4; 
exp.condLabel = {'Faces', 'Objects', 'Scenes', 'Scrambled'};
exp.numImagesPerBlock 	= 20; 
exp.timePerBlock        = 16; %sec -- must equal the time per block / time per image
exp.timePerImage        = .600; % sec
exp.timeBetweenImages   = .200; % sec
exp.timePerRestBlock    = 10; % sec
exp.imageDisplaySizePx  = 800;%256;
exp.quitKey             = KbName('q');
exp.respKeys            = KbName('b');%[KbName('1') KbName('2') KbName('3') KbName('4') KbName('1!') KbName('2@'), KbName('3#') KbName('4$')];
exp.triggerKey          = KbName('t');%[KbName('=+') KbName('+')];

blockOrderHelper = [];
exp.imToRepeat = [];
for i=1:exp.numBlocksPerCond
    blockOrderHelper = [blockOrderHelper randperm(exp.numConds)];
    % task: 1 time per block, repeat an image
    temp = randperm(exp.numImagesPerBlock);
    exp.imToRepeat = [exp.imToRepeat temp(1:exp.numConds)];
end;

% interleave blocks of rest:
exp.blockOrder = zeros(1, exp.numBlocksPerCond*exp.numConds*2+1);
exp.blockOrder(2:2:end) = blockOrderHelper;

exp.numRestBlocks = sum(exp.blockOrder == 0);
exp.totalImagesPerCond = exp.numImagesPerBlock * exp.numBlocksPerCond;


exp.totalTime = exp.numRestBlocks * exp.timePerRestBlock + exp.numBlocksPerCond * exp.timePerBlock * exp.numConds;
exp.totalTRs = exp.totalTime / 2;


%-------------------------------------------------------------------------
% set up event timing
%-------------------------------------------------------------------------
disp('set up event timing')

eventNumber = 1;
D.eventStartTime(eventNumber) = 0;
D.eventEndTime(eventNumber) = exp.timePerRestBlock;
D.eventCond(eventNumber) = exp.blockOrder(1); % fixation
exp.blockStartTime(1) = 0;
exp.blockEndTime(1) = exp.timePerRestBlock;

% figure out which of the 80 images go in which block, for all conds
for i=1:exp.numConds
    imageHelper(i).imOrder = randperm(exp.totalImagesPerCond);
end;

for i=2:length(exp.blockOrder)
    if exp.blockOrder(i) == 0
        eventNumber = eventNumber +1;
        D.eventStartTime(eventNumber)= D.eventEndTime(eventNumber-1);
        D.eventEndTime(eventNumber) = D.eventStartTime(eventNumber)+exp.timePerRestBlock;
        D.eventCond(eventNumber) = exp.blockOrder(i);
        D.eventImageNum(eventNumber) = 0;
        D.eventFixationTest(eventNumber) = 0;
        exp.blockStartTime(i) = D.eventStartTime(eventNumber);
        exp.blockEndTime(i) = D.eventEndTime(eventNumber);

    else %stimulus block
        fixationTest = randi(exp.numImagesPerBlock-2)+1; % make sure it's not first or last
        blockIms = imageHelper(exp.blockOrder(i)).imOrder(1:exp.numImagesPerBlock); % take the first N
        imageHelper(exp.blockOrder(i)).imOrder(1:exp.numImagesPerBlock)=[]; % remove those ims
       
        for j = 1:exp.numImagesPerBlock

            % event: display image
            eventNumber = eventNumber +1;
            D.eventStartTime(eventNumber) = D.eventEndTime(eventNumber-1);
            D.eventEndTime(eventNumber) = D.eventStartTime(eventNumber) + exp.timePerImage;
            D.eventEndTime(eventNumber) = D.eventStartTime(eventNumber) + exp.timePerImage;
            D.eventCond(eventNumber) = exp.blockOrder(i);
            D.eventFixationTest(eventNumber) = 0;
            D.eventImageNum(eventNumber) = blockIms(j);
            if j==1
                exp.blockStartTime(i) = D.eventStartTime(eventNumber);
            end;
            if j==fixationTest
                D.eventFixationTest(eventNumber) = 1;
                D.eventImageNum(eventNumber) = blockIms(j-1); % insert a oneback
            else
                D.eventFixationTest(eventNumber) = 0;
            end;
            
            % event: display fixation after image
            eventNumber = eventNumber +1;
            D.eventStartTime(eventNumber) = D.eventEndTime(eventNumber-1);
            D.eventEndTime(eventNumber) = D.eventStartTime(eventNumber) + exp.timeBetweenImages;
            D.eventCond(eventNumber) = exp.numConds + 1;  % make these interleaved 'fixations' as a condition at the end...
            D.eventImageNum(eventNumber) = 0;
            
            if j==exp.numImagesPerBlock
                exp.blockEndTime(i) = D.eventEndTime(eventNumber);
            end
        end
    end
end



%-------------------------------------------------------------------------
% set up psychtoolbox windows
%-------------------------------------------------------------------------
disp('set up ptb windows')


window.bgColor = [255 255 255];
[onScreen, screenRect] = Screen('OpenWindow',numScreens);
Screen('FillRect', onScreen, window.bgColor);
window.screenX = screenRect(3);
window.screenY = screenRect(4);
window.screenDiag = sqrt(window.screenX.^2 + window.screenY.^2);


%-------------------------------------------------------------------------
% load all the images into textures
%-------------------------------------------------------------------------
disp('load all images')

for i=1:length(exp.condLabel)
    ims = dir(['ImageFiles/' exp.condLabel{i} '/*.jpg']);
    for thisIm = 1:length(ims)
        if ims(thisIm).name(1) == '.'
            ims(thisIm).name = ims(thisIm).name(3:end);
        end
        image = imread(['ImageFiles/' exp.condLabel{i} '/' ims(thisIm).name]);
        %image = imresize(image,4);
        displayRects(i, thisIm).rect = calculateDisplayRect(size(image,1), size(image,2), exp.imageDisplaySizePx, window.screenX/2, window.screenY/2);
        tex(i, thisIm) = Screen('MakeTexture', onScreen, image);
    end;
end;

dotimage = imread(['ImageFiles/dot2.jpg']);
dotdisplayRects = calculateDisplayRect(size(dotimage,1), size(dotimage,2), exp.imageDisplaySizePx, window.screenX/2, window.screenY/2);
dottexture = Screen('MakeTexture', onScreen, dotimage);

targetRect = CenterRectOnPoint([0 0 exp.imageDisplaySizePx exp.imageDisplaySizePx] + [-20 -20 +20 +20], window.screenX/2, window.screenY/2);

%-------------------------------------------------------------------------
% save the .mat file with all the planned presentations
%-------------------------------------------------------------------------
savePath = fullfile(save_root, 'DataFiles', SID);
mkdir(pwd, savePath);
save(fullfile(savePath, [SID '_Run' int2str(runNum) '_' datestr(now, 30) '.mat']), 'exp', 'D');

% Save the PRT file
generatePRTfile(exp, D, fullfile(savePath, [exp.name '_' SID '.prt']));


%-------------------------------------------------------------------------
% spit out experiment information:
%-------------------------------------------------------------------------
clc
disp(sprintf('\n'))
disp(sprintf('Experiment Name: %s\n', exp.name))
disp(sprintf('Num Conditions: %d\n', exp.numConds))
disp(sprintf('Blocks Per Cond: %d\n', exp.numBlocksPerCond))
disp(sprintf('\n'))
disp(sprintf('Total TRs: %d\n', exp.totalTRs))
disp(sprintf('Total Time: %1.2f\n', exp.totalTime/60))
disp(sprintf('\n'))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------------------------------------------
% run it!
%-------------------------------------------------------------------------
HideCursor
% get trigger
Screen('TextSize', onScreen, 120)
% text = 'secondary task: Press ''1'' when there is a red frame around an object';
% [nr obr] = Screen('TextBounds', onScreen, text);
% rect = CenterRectOnPoint(obr, window.screenX/2, window.screenY/2);
% Screen('DrawText', onScreen, text, rect(1), rect(2));

text = 'Press the button when an image repeats!';
[nr obr] = Screen('TextBounds', onScreen, text);
rect = CenterRectOnPoint(obr, window.screenX/2, window.screenY/2 - 100);
Screen('DrawText', onScreen, text, rect(1), rect(2));

Screen('Flip', onScreen);
disp('waiting for trigger')
[keyIsDown,secs,keyCode] = KbCheckM;
while sum(keyCode(exp.triggerKey))==0
    [keyIsDown,secs,keyCode] = KbCheckM;
end


% start master clock
startTime = GetSecs;
disp('triggered')

% while not done
currentEvent = 1;


while (1)
    % if current time is at the clock time for the next event
    if (GetSecs-startTime)>D.eventStartTime(currentEvent)
        % play event
        if D.eventCond(currentEvent) == 0 
            % fixation
%             if D.eventFixationTest(currentEvent) == 1
%                 Screen('FillOval', onScreen, [255 0 0], CenterRectOnPoint([0 0 7 7], window.screenX/2, window.screenY/2));
%             else
%                 Screen('FillOval', onScreen, [0 0 0], CenterRectOnPoint([0 0 7 7], window.screenX/2, window.screenY/2));
%             end;
            %Screen('FillOval', onScreen, [0 0 0], CenterRectOnPoint([0 0 7 7], window.screenX/2, window.screenY/2));
             Screen('DrawTexture', onScreen, dottexture);
            disp(['condition: ' num2str(D.eventCond(currentEvent)) ' catch: ' num2str(D.eventFixationTest(currentEvent))])
        
        elseif D.eventCond(currentEvent) ==(exp.numConds + 1)
            % blank between images during a main block
            Screen('FillRect', onScreen, window.bgColor)
            
        else
            % main block when images are displayed
            
            Screen('DrawTexture', onScreen, tex(D.eventCond(currentEvent), D.eventImageNum(currentEvent)), [], displayRects(D.eventCond(currentEvent), D.eventImageNum(currentEvent)).rect);
            disp(['condition: ' exp.condLabel{D.eventCond(currentEvent)} ' imageNum: ' num2str(D.eventImageNum(currentEvent))]);
%             if D.eventFixationTest(currentEvent) == 1
%                 Screen('FrameRect', onScreen, [255 0 0], targetRect, 3);
%             end;
        end;
        
        Screen('Flip', onScreen);
        D.actualEventTime(currentEvent) = GetSecs-startTime;
        currentEvent = currentEvent+1;
    end
    
    % if were at the last event end, wait until the end duration
    % other wise, listen for a response until it's time for the next
    % event...
    if currentEvent > length(D.eventCond)
        while (GetSecs-startTime) < D.eventEndTime(currentEvent-1); end
        break;
    else

        % wait for key until next event
        thisResponse = 0;
        thisRT = 0;
        while(GetSecs-startTime<D.eventStartTime(currentEvent))
            [keyIsDown,secs,keys] = KbCheckM;
            if keys(exp.quitKey)
                sca;
                error('User quit!');
            end
            if any(keys(exp.respKeys))
                temp = keys(exp.respKeys);
                thisResponse = temp(1);
                thisRT = GetSecs-startTime;
            end
        end
        D.response(currentEvent) = thisResponse;
        D.rt(currentEvent) = thisRT;
    end

end

WaitSecs(6);
%-------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%-------------------------------------------------------------------------
% close psychtoolbox windows
%-------------------------------------------------------------------------
t=GetSecs; while(GetSecs-t)<1; end
Screen('CloseAll');


%-------------------------------------------------------------------------
% plot response data:
%-------------------------------------------------------------------------
figure
plot(D.eventFixationTest==1), hold on, plot(D.rt>0, 'r')
xlabel('run time')
print(gcf, '-djpeg', fullfile(savePath, ['responseData_' num2str(runNum) '.jpg']));

% plot timing
figure
plot(D.eventStartTime-D.actualEventTime)
xlabel('event number')
ylabel('seconds')
title('difference between expected and actual time')
print(gcf, '-djpeg', fullfile(savePath, ['timing_' num2str(runNum) '.jpg']));


close all
%-------------------------------------------------------------------------
% HELPER FUNCTIONS
%-------------------------------------------------------------------------
function generatePRTfile(exp, D, filename)
% generate PRT File


condColor = ...
   {[255 16 0],
    [204 102 0],
    [255 255 0],
    [102 204 0],
    [51 204 204],
    [145 43 128]};
TRdur         = 1;


% open file
fid = fopen(filename, 'w');


% header information
fprintf(fid,'\n');
fprintf(fid,'FileVersion:        1\n');
fprintf(fid,'ResolutionOfTime:   Volumes\n');
fprintf(fid,'Experiment:         %s\n', exp.name);
fprintf(fid,'BackgroundColor:    0 0 0\n');
fprintf(fid,'TextColor:          255 255 255\n');
fprintf(fid,'TimeCourseColor:    255 255 255\n');
fprintf(fid,'TimeCourseThick:    3\n');
fprintf(fid,'ReferenceFuncColor: 0 0 80\n');
fprintf(fid,'ReferenceFuncThick: 3\n');
fprintf(fid,'NrOfConditions:     %d\n',exp.numConds);
fprintf(fid,'\n');

% condition information
for thisCond = 1:exp.numConds

    % condition name
    fprintf(fid, '%s\n', exp.condLabel{thisCond});

    % number of events
    fprintf(fid, '%d\n', sum(exp.blockOrder==thisCond));

    % onsets and offsets in TRs
    onsets = exp.blockStartTime(exp.blockOrder==thisCond)/TRdur + 1;
    offsets = exp.blockEndTime(exp.blockOrder==thisCond)/TRdur; % don't add 1 for prt file! + 1;
    for thisTR = 1:length(onsets)
        fprintf(fid, '  %2.0f %2.0f\n', onsets(thisTR), offsets(thisTR));
    end;

    % color
    fprintf(fid,'Color: %d %d %d\n\n', condColor{thisCond});

end;
fclose(fid);


%-------------------------------------------------------------------------
function displayRect = calculateDisplayRect(imH, imW, dispSize, centerX, centerY)
% given an arbitrary image size
% generate a rect size, centered on the Screen, that makes the maximum
% dimension equal to N pixels


aspectRatio = imH/imW;

if aspectRatio == 1
    % square
    newHeight = dispSize;
    newWidth = dispSize;
    
elseif aspectRatio > 1
    % tall
    newHeight = dispSize;
    newWidth = dispSize/aspectRatio;
    
else aspectRatio < 1
    % fat
    newWidth = dispSize;
    newHeight = dispSize * aspectRatio;
    
end

rect = round([0 0 newWidth newHeight]);
displayRect = CenterRectOnPoint(rect, centerX, centerY);


%-------------------------------------------------------------------------
function [keyIsDown,secs,keyCode] = KbCheckM(deviceNumber)
% [keyIsDown,secs,keyCode] = KbCheckM(deviceNumber)
% check all attached keyboards for keys that are down
%
% Tim Brady and Oliver Hinds 
% 2007-07-18

  if(~IsOSX)
      if exist('deviceNumber', 'var')
        [keyIsDown, secs, keyCode] = KbCheck(deviceNumber);
      else
        [keyIsDown, secs, keyCode] = KbCheck();
      end 
    return
    %error('only call this function on mac OS X!');
  end
  
  if nargin==1
    [keyIsDown,secs,keyCode]= PsychHID('KbCheck', deviceNumber);
  elseif nargin == 0
    keyIsDown = 0;
    keyCode = logical(zeros(1,256));
    
    invalidProducts = {'USB Trackball'};
    devices = PsychHID('devices');
    for i = 1:length(devices)
      if(strcmp(devices(i).usageName, 'Keyboard') )
	for j = 1:length(invalidProducts)
	  if(~(strcmp(invalidProducts{j}, devices(i).product)))
	    [down,secs,codes]= PsychHID('KbCheck', i);
        codes(83) = 0;
	  
	    keyIsDown = keyIsDown | down;
	    keyCode = codes | keyCode;
	  end
	end
      end
    end
  elseif nargin > 1
    error('Too many arguments supplied to KbCheckM');
  end

return