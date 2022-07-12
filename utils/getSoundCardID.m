function deviceid = getSoundCardID()
    % Returns external sound card if detected to be used by PTB
    deviceid = [];
    devices = PsychPortAudio('GetDevices');
    for dev = devices
        if(contains(dev.DeviceName, 'USB Audio'))
            deviceid(1) = dev.DeviceIndex;
            break;
        end
    end
end