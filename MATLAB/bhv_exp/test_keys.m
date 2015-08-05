%31 index ; 32 middle;.... scanner ...225 ^   %left shift (?)

keyCodes(1:256) = 0;
keyIsDown=0;
while ~keyIsDown%sum(double(keyCodes))==0%
                       [keyIsDown, secs, keyCodes, deltaSecs] = KbCheck;
end
key_pressed=find(double(keyCodes))


% Gamepad('Unplug')%so it can recognize config after (un)plugging gamepad
% numGamepads = Gamepad('GetNumGamepads') %usually 1
% numButtons = Gamepad('GetNumButtons', 1)
% 
% buttons=[Gamepad('GetButton', 1, 5) Gamepad('GetButton', 1, 6) Gamepad('GetButton', 1, 7) Gamepad('GetButton', 1, 8)];
% while sum(buttons)==0
% buttons=[Gamepad('GetButton', 1, 5) Gamepad('GetButton', 1, 6) Gamepad('GetButton', 1, 7) Gamepad('GetButton', 1, 8)];
% end
% buttons
