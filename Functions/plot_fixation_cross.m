function plot_fixation_cross(p,flip,fixcolor,dontclear)
%plots fixation cross
% flip: 1 flips screen, 0 does not

%initialize parameters
cx = (p.wRect(3)/2);
cy = (p.wRect(4)/2);
fixlinelength = 10;
fixcross = [cx-fixlinelength cx+fixlinelength cx cx; cy cy cy-fixlinelength cy+fixlinelength];
fixwidth = 2.5;
if ~exist('fixcolor')
    fixcolor = [255 0 0];
end
if ~exist('dontclear')
    dontclear = 0;
end

% draw black fixation cross
Screen('DrawLines',p.whandle,fixcross,fixwidth,fixcolor);

if flip == 1
    Screen('Flip', p.whandle,0,dontclear);
end

