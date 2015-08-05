


function bhv_exp_GC_E3
%% Gender recognition task 3 %%
    %{
        Obtain a run number from GUI-enabled user input.
        Read and display face data one at a time and wait for response.
        On obtaining response, pass to anl_acc_consist_GC_E2 for 
        preliminary analysis. Output a data file and info file about the 
        run. 
    %}

%% Set Priority %%
% Change the priority in case of issues with synching
Priority(2);

%% Inputting participant information %%
% input session info (if subj is 0, it is a test run)
defAns={'0', 'M', '20'};
answ = inputdlg({'Subject number:', 'Gender (M-male, F-female):', 'Age:'},...
                     'Session info', 1, defAns);
                 
subj=str2num(char(answ(1))); %#ok<ST2NM>
subjid=['s', sprintf('%02.0f', subj)];
gend=char(answ(2)); %#ok<NASGU>
age=char(answ(3)); %#ok<NASGU>


%% Get static resolution read 
% (i.e. at matlab startup); stop if not correct
ScreenSz=get( 0, 'ScreenSize' );
if ScreenSz(3)~= 1344 || ScreenSz(4)~=756%unstretched (full 768) 
    error('Please adjust screen resolution to 1344 X 756 and restart Matlab!')
end

%% check for button box

% Gamepad('Unplug')%so it recognizes config after (un)plugging button box (/any USB device)
% if Gamepad('GetNumGamepads')~=1
%     error('Button box not recognized!')
% end


%% Output file info (stop/overwrite if this subj&session already collected)
cd('/Users/VisRecLab/VisRecLab_Code_Repository/MATLAB/E3')
res_fold=['bhv_results_E3/', subjid, '/'];

[jnk1, jnk2]=mkdir(res_fold); %#ok<ASGLU,NASGU>

for run_number=1:6
    resfile_nm=[res_fold, subjid, '_run', num2str(run_number), '.txt'];
    infofile_nm=[res_fold, subjid, '_run', num2str(run_number), '_info.txt'];

    %test to see if info file exists for this subj; exit if it does
    if ((fopen(infofile_nm,'rt')) ~= -1) %&& subj>0 %subj 0 are test runs for the script --> can be overwitten

        disp(strcat('Datafile already exists for subject ', num2str(subj), ' and run ', num2str(run_number)));
        disp('Press 1 to overwrite or 2 to exit (followed by enter)!')
        strResponse = input('1/2: ');
        while strResponse~=1 && strResponse~=2
            strResponse = input('Please input 1/2:');
        end

        if strResponse==2
            return
        else delete(resfile_nm, infofile_nm)
             %[status, message, messageid] = rmdir(subjid);%[jnk1, jnk2]=mkdir(res_fold);
        end
    end
end

%% PsychToolbox and Display initialization

Screen('Preference', 'SkipSyncTests', 0)%oldEnableFlag   

try 
    %shorten the internal calibrations and display tests (max 5s) during debugging
    %restore settings (0 - no skip) at end of script
    %need this for some of the os x things?
    AssertOpenGL;
    %choose the display screen (needed if multiple monitors attached)
    screenNumber = max(Screen('Screens'));
    %run code to find the device number for a wired apple keyboard
    kbDev=local_findKeyboard; %#ok<NASGU>
    %need to call Gamepad<-PsychHID once to get the slow initial loading of 
    %the mex file out of the way...
    
    
    
   %used test_keys script to find key ids
    esc_key = 41;%KbName('escape'); %this key kills script during the experiment
    g_key=10; %'g' key
    enter_key = 40;%KbName('enter') gives diff number ?!; used to move on past instructions
    key1=32; key2=39;%%keys:3 and 0
    
    
    
    black=BlackIndex(screenNumber); %bkgd color for the inst will be black
    %white=WhiteIndex(screenNumber); %bkgd color for experiment will be white
    w=Screen('OpenWindow', screenNumber);
    nrSamples=10; [monitorFlipInterval nrValidSamples stddev] =Screen('GetFlipInterval', w, nrSamples); %#ok<NASGU,NCOMMA,ASGLU>
    slack = monitorFlipInterval/2; %divide by 2 (or only for OpenWindow stereomode=1?;
    
    HideCursor;
    %get / display screen 
    Screen(w,'FillRect', black);%white
    %always writes to an offscreen buffer window à flip to see changes  made
    Screen('Flip', w);
    % set font; display text
    Screen('TextFont',w, 'Times');
    Screen('TextSize',w, 18);
    Screen('TextStyle', w, 0);
    Screen('DrawText', w, 'Preloading images...', 100, 130, [255, 0, 0, 255]);
    Screen('Flip', w);
    
    
%% Display and image loading procedures   
    
    
    % design fixation crosses / prompt
    [y, x]=meshgrid(1:30,1:30);
    x=(x>12)&(x<17); y=(y>12)&(y<17);
    fixation_dark=double(x | y)*80;    
    fixation_grey=double(x | y)*153;

    
    % load images and corr resp           
     im_mat_fl='stims/stim_mat.mat';
     load(im_mat_fl, 'im_mat');
     %im_mat=load('stims/stim_mat.mat');
                    
    
    % read trial order, position (left/right)
    fl=['stims_ord_E3/', subjid, '_ord_mat.txt'];
    ord_id_mat=dlmread(fl);
    %ord_gend_mat=single(ord_id_mat>60)+1;% 1-male, 2-female
    
    %lr_ind=randperm(240)>120;%repmat([0; 1], [120 1]);

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%% parameters %%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
       

    %totalEvents_perRun=1770;
    
    tmp=rand(295, 1); % ?
    tmp=tmp*0.4;
    tmp=tmp+0.2;
    fixationTime_vect=[1; tmp];%%min: 0.2, max: 1 
    stimPresLength_max = 4.0;    
    respTime_max=2.0;%0.4
    
    instructionsToUse=1;
    local_doInstructions(w, instructionsToUse, black, enter_key, esc_key)
       
    for run_number=1:6
        
        % Initialize the ordering matrix
        ord_id_vect=ord_id_mat(:,run_number*2-1:run_number*2);
        
        resfile_nm=[res_fold, subjid, '_run', num2str(run_number), '.txt'];
        infofile_nm=[res_fold, subjid, '_run', num2str(run_number), '_info.txt'];
        
        %open a file in w=write mode and t=text mode (new line feed)
        fid = fopen(infofile_nm,'wt');
        dlmwrite(resfile_nm, zeros(0,9))  


    
        %print relevant stuff in header info
        fprintf(fid,'%s \n','<><><><><><><><>');
        fprintf(fid,'%s %s \n','Begin:', datestr(now));
        fprintf(fid,'%s %s \n','Matlab version ', version);
        PTversion=PsychtoolboxVersion;
        fprintf(fid,'%s %s \n','Psychtoolbox version ', PTversion);
        fprintf(fid,'%s %s %s %s %s %s \n','Subjid:', subjid);
        fprintf(fid,'%s %i \n','Run Number:', run_number);    
        fprintf(fid,'%s \n','<><><><><><><><>');   
        fprintf(fid,'%s \n','Columns info in data file:');
        fprintf(fid,'%s \n','1. left indvd 2. # right indvd ');
        fprintf(fid,'%s \n','3. response (left - 1 :: right - 2) 4. RT ');
        fprintf(fid,'%s \n','<><><><><><><><>');
        fprintf(fid,'%s \n','Columns info in (this) info file:');
        fprintf(fid,'%s \n','1. Stimulus start time (from trial start) 2. Stimulus off-time(from stimulus start time)');
        fprintf(fid,'%s \n \n','3. RT or max response duration, if no response (from stimulus start time)');
    
    
    
        Screen('PutImage', w, fixation_grey);
        Screen('Flip', w); %show offscreen buffer that has fixation  
        runStartTime=GetSecs;
        trialStartTime = runStartTime;
        

        stimStartTime = trialStartTime+fixationTime_vect(1, 1)-slack;
        stimEndTime_max = stimStartTime+stimPresLength_max;%slack taken out already
        respEndTime=stimEndTime_max+respTime_max;
    
    
%% Main Loop %%
    %{
    This section will be modified depending on stimulus set being
    presented. Currently for the gender recognition project, this will
    display two images taken from an ordering unique to this subj.
    %}

        for trial_k=1:295
               

                trial_id_code1=ord_id_vect(trial_k, 1);
                trial_id_code2=ord_id_vect(trial_k, 2);
                im1=im_mat(:,:,:, trial_id_code1); %#ok<NODEF>
                im2=im_mat(:,:,:, trial_id_code2);
                stim=cat(2, im1, zeros(size(im2, 1), size(im1, 2)*2, 3), im2);
                    
                    
                Screen('PutImage', w, stim); % ready image


                WaitSecs('UntilTime', stimStartTime); % interval       
                Screen('Flip', w); % display 
                stimStartTime_act=GetSecs;

                Screen('PutImage', w, fixation_grey);


                keyCodes(1:256) = 0;
                
                
                %%% button press response or stim display expires
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                while sum(double(keyCodes([key1 key2 g_key])))==0 && (GetSecs < stimEndTime_max)                                
                   [keyIsDown, secs, keyCodes, deltaSecs] = KbCheck;            %#ok<NASGU,ASGLU>
                   WaitSecs(0.01);
                end
                stimEndTime_act=GetSecs;

                stimTime_act=stimEndTime_act-stimStartTime_act;
                RT=stimTime_act;

           
                Screen('Flip', w); 


                %%% button press after stim display expires
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if sum(double(keyCodes([key1 key2 g_key])))==0
                    while sum(double(keyCodes([key1 key2 g_key])))==0 && (GetSecs < respEndTime)
                       [keyIsDown, secs, keyCodes, deltaSecs] = KbCheck; %#ok<NASGU,ASGLU>
                       WaitSecs(0.01);
                    end
                    RT=GetSecs-stimStartTime_act;
                end
                
                %if sum(double(keyCodes([key1 key2 esc_key])))==0 && (GetSecs > respEndTime)
                    Screen('PutImage', w, fixation_dark);        
                    Screen('Flip', w);
                %end
                    


                if ~keyCodes(g_key)

                    %%%recorded time stamps 
                    stimStartTime_rec=stimStartTime_act-trialStartTime;
                    stimEndTime_rec=stimEndTime_act-stimStartTime_act;

                    %%%set up timing for next trial
                    trialStartTime = GetSecs;
                    stimStartTime = trialStartTime+fixationTime_vect(trial_k+1, 1)-slack;       %fixationTime_check=fixationTime_vect(trial_k+1, 1)
                    stimEndTime_max = stimStartTime+stimPresLength_max;%slack taken out already     
                                                                                                
                                                                                                
                    respEndTime=stimEndTime_max+respTime_max;

                    %%%write results to txt files during fixation interval
                    if sum(double(keyCodes([key1 key2])))>0 % if key pressed?
                        resp=find(keyCodes([key1 key2]), 1, 'first'); % ?
                        RT_act=RT;
                    else resp=NaN; RT_act=NaN;
                    end
                    
                    %store results for stimuli, append to file
                    res_vect=[trial_id_code1 trial_id_code2 resp RT_act];
                    
                    dlmwrite(resfile_nm, res_vect, '-append') % analysis file           
                    fprintf(fid,'%02.3f %02.3f %02.3f \n', stimStartTime_rec, stimEndTime_rec, RT); % info file



                else ShowCursor;
                     Screen('CloseAll');
                     error('User interrupted the trial by pressing "g"...');
                end

        end
        
        % run preliminary analysis on this trial                
        % trial_k=trial_k uncomment this if issues come up

        if trial_k~=295 %if debugging, use some random test values
            RT_mn='DEBUG_VALUE'; consist='DEBUG_VALUE';
        else 
            [RT_mn, consist, min, maxm, total_rightvote, total_leftvote, self_consist]=anl_acc_consist_GC_E3({resfile_nm}, subjid, run_number);
        end

        fprintf(fid,'%s \n','<><><><><><><><>');
        fprintf(fid,'%s %02.2f \n','RT (mean): ', RT_mn);
        fprintf(fid,'%s %02.2f \n','Consistency: ', consist);
        fprintf(fid,'%s %02.2f \n','Self Consistency: ', self_consist);
        fprintf(fid,'%s \n','<><><><><><><><>');
        fprintf(fid,'%s %s \n','End:', datestr(now));         
        fclose(fid);
        

        
        local_doEndScreen(w, black, run_number, esc_key, consist, min, maxm, total_rightvote, total_leftvote, self_consist);
        
    end
    
    ShowCursor;
    Screen('CloseAll');
    
catch exception1
    
    ShowCursor;
    Screen('CloseAll');

    throw(exception1);
end

    

function local_doInstructions(window, instNum, bkgdColor, enter_key, esc_key)
%% Display instructions to participants
%persistent scope of these variable is this function -- but no waste
%w/multiple calls

inst_horzpos=50;
top_vertpos=100;
inst_vertpos=30;
inst_color=250;
%inst_key = KbName('space');%this will be the key to advance the inst screen

Screen(window,'FillRect', bkgdColor);
Screen('TextFont',window, 'Arial');
Screen('TextSize',window, 18);
%0=normal,1=bold,2=italic,4=underline,8=outline,32=condense,64=extend
Screen('TextStyle', window, 1);


switch instNum
        case {1}
                Screen('DrawText', window, 'In this experiment you will be presented with pairs of male faces.', inst_horzpos, top_vertpos+inst_vertpos, inst_color); 
                Screen('DrawText', window, 'Your task is to select the more masculine face from each pair.', inst_horzpos, top_vertpos+inst_vertpos*2, inst_color);
                Screen('DrawText', window, 'If the left face is more masculine, press the 3 key.', inst_horzpos, top_vertpos+inst_vertpos*3, inst_color);
                Screen('DrawText', window, 'If the right face is more masculine, press the 0 key.', inst_horzpos, top_vertpos+inst_vertpos*4, inst_color);
                Screen('DrawText', window, ' ', inst_horzpos, top_vertpos+inst_vertpos*5, inst_color);
                Screen('DrawText', window, 'Try to respond in a timely manner.', inst_horzpos, top_vertpos+inst_vertpos*6, inst_color);              
                Screen('DrawText', window, 'Press enter to move on.', inst_horzpos, top_vertpos+inst_vertpos*8, inst_color);

                
                Screen('Flip', window);
            otherwise
                Screen('DrawText', window, 'No instructions found for this section -- sorry!', inst_horzpos, top_vertpos+inst_vertpos, inst_color);
                Screen('Flip', window);
end

keyCodes(1:256) = 0;
while sum(double(keyCodes([enter_key esc_key])))==0
    [keyIsDown, secs, keyCodes, deltaSecs] = KbCheck; %#ok<ASGLU,NASGU>
    
end

if keyCodes(esc_key)
        ShowCursor;
        Screen('CloseAll');
        error('User interrupted the trial by pressing escape...');
end

Screen(window,'FillRect', bkgdColor);
Screen('Flip', window);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display summary info on this run %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_doEndScreen(window, bkgdColor, run_number, esc_key, consist, min, maxm, total_rightvote, total_leftvote, self_consist)%inputDev, , enter_key


call_exp=1;
if run_number==3
    call_exp=2;
elseif run_number==6
    call_exp=3;
end

inst_horzpos=50;
top_vertpos=100;
inst_vertpos=30;
inst_color=250;

Screen(window,'FillRect', bkgdColor);
Screen('Flip', window);
Screen('TextFont',window, 'Arial');
Screen('TextSize',window, 18);
%0=normal,1=bold,2=italic,4=underline,8=outline,32=condense,64=extend
Screen('TextStyle', window, 0);

Screen('DrawText', window, ['End of run ', num2str(run_number), ' (out of 6).'], inst_horzpos, top_vertpos+inst_vertpos, inst_color);
consist_txt=sprintf('Correlation to other participants: %02.2f', consist);
Screen('DrawText', window, consist_txt, inst_horzpos, top_vertpos+inst_vertpos*2);
self_consist_txt=sprintf('Your consistency: %02.2f%', self_consist, '%');
Screen('DrawText', window, self_consist_txt, inst_horzpos, top_vertpos+inst_vertpos*3);
lr_text=sprintf('You picked the image on the right a total of %2.2f times and the image on the left %2.2f', total_rightvote, total_leftvote);
Screen('DrawText', window, lr_text, inst_horzpos, top_vertpos+inst_vertpos*4);

Screen('TextColor',window, [255 255 255]);
if call_exp==1
    Screen('DrawText', window, 'Take a short break if needed. Please call the experimenter to continue!', inst_horzpos, top_vertpos+inst_vertpos*10);
elseif call_exp==2
    Screen('DrawText', window, 'Take a short break if needed.  Please call the experimenter to continue!', inst_horzpos, top_vertpos+inst_vertpos*15);
elseif call_exp==3
    Screen('DrawText', window, 'You ranked these images as being least masculine and most masculine during this run.', inst_horzpos, top_vertpos+inst_vertpos*5, inst_color);
    min_img=imread(strcat('stims/stim10', sprintf('%02d', min), '1.tif'));
    maxm_img=imread(strcat('stims/stim10', sprintf('%02d', maxm), '1.tif'));
    disp_final=cat(2, min_img, zeros(size(maxm_img, 1), size(min_img, 2)*2, 3), maxm_img);
    Screen('PutImage', window, disp_final);
    Screen('DrawText', window, 'You are finished. Please call the experimenter!', inst_horzpos, top_vertpos+inst_vertpos*15);
end
Screen('Flip', window);

keyCodes(1:256) = 0;

if call_exp>0
    while ~keyCodes(esc_key)
        [keyIsDown, secs, keyCodes, deltaSecs] = KbCheck; %#ok<NASGU,ASGLU>
    end
else while ~keyCodes(enter_key)
        [keyIsDown, secs, keyCodes, deltaSecs] = KbCheck; %#ok<NASGU,ASGLU>
    end
end
% ShowCursor;
% Screen('CloseAll');

function kbDev=local_findKeyboard
%% Find keyboard
%{
 Parse through the list of input devices and get the numbers for any
 attached keyboards. Need to do this because the actual number of any
 given keyboard varies depending on the other input devices that are
 attached and when they were attached. For some reason, my Logitech
 Wireless mouse doesn't show up at all in the device list OR, even
 worse, shows up, but also seems to create a "ghost" entry for a
 Logitech keyboard, usually as the first keyboard in the list!!!

 Some suggestions about this:
 1. Don't ever use a Logitech mouse while try to run PTB.
 2. Check if the manufacturer is Logitech and, if so, reject it
 3. Create a list of all keyboards with some precedence for Apple
    keyboards that are not connected via bluetooth

 I implement #3 below, it is ugly, but at this point in the
 experiment, time ain't so critical, just have to calculate this once
 (unless some perverse person plugs in or removes an input device
 during the experiment!)
%}
nDevs = PsychHID('NumDevices');
devices = PsychHID('Devices');
kbDev = 0;

% search for a hard connected apple keyboard
for dv = 1:nDevs,
    if (strcmp(devices(dv).usageName, 'Keyboard') && strcmp(devices(dv).manufacturer, 'Apple') && ~strcmp(devices(dv).transport, 'Bluetooth'))
        kbDev = dv;
        disp('Found wired apple keyboard.');
        break;
    end
end

% search for any apple keyboard
if (~kbDev)
    for dv = 1:nDevs,
        if (strcmp(devices(dv).usageName, 'Keyboard') && strcmp(devices(dv).manufacturer, 'Apple'))
            kbDev = dv;
            disp('Found bluetooth apple keyboard.');
            break;
        end
    end
end

% search for any keyboard
if (~kbDev)
    for dv = 1:nDevs,
        if (strcmp(devices(dv).usageName, 'Keyboard'))
            kbDev = dv;
            disp('Warning! The only keyboard found was non-apple.');
            disp('Logitech mice sometimes produce spurious keyboards.');
            break;
        end
    end
end

% no keyboards/mice of any sort were found
if (~kbDev)
    error('Sorry, I could not find a keyboard for responses.\n');
end