% Wait for R key button press to continue to next sub run
waitToContinue = true;
while waitToContinue == true
   [keyIsDown, secs, keyCode] = KbCheck();
   if keyCode(21) % This is the R key on Macs
       waitToContinue = false;
   elseif keyCode('R') % This is the R key on Windows 10
       waitToContinue = false;
   end
end