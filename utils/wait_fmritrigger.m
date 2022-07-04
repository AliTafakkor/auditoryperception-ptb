%Wait for fMRI trigger
waitforTrig = true;
while waitforTrig == true
   [keyIsDown, secs, keyCode] = KbCheck(-1);
   if keyCode(p.escapeKey)
      waitforTrig = false;
   elseif sum(keyCode(p.triggerKey)) ~= 0   % This is the one for the FORP box...
      disp('+')
      waitforTrig = false;
   end
end