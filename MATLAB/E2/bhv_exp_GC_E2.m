

function bhv_exp_GC_E2%(subj, run_number)
% The main function. Obtain a run number from GUI-enabled user input
% Read and display face  data one at a time and wait for response.
% On obtaining response, pass to anl_acc_consist_GC_E2 for preliminary
% analysis. Output a data file and info file about the run.

Priority(0); % set this higher to fix SOME synch issues

%%%input session info (if subj is 0, it is a test run)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
defAns={'0', 'M', '20'};
answ = inputdlg({'Subject number:', 'Gender (M-male, F-female):', 'Age:'},...
                     'Session info', 1, defAns);
                 
subj=str2num(char(answ(1)))
subjid=['s', sprintf('%02.0f', subj)];
gend=char(answ(2));
age=char(answ(3));


%%%get static resolution read (i.e. at matlab startup); stop if not correct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScreenSz=get( 0, 'ScreenSize' );
if ScreenSz(3)~= 1344 || ScreenSz(4)~=756%unstretched (full 768) 
    error('Please adjust screen resolution to 1024 X 768 and restart Matlab!')
end

%%%check for button box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Gamepad('Unplug')%so it recognizes config after (un)plugging button box (/any USB device)
% if Gamepad('GetNumGamepads')~=1
%     error('Button box not recognized!')
% end


%%%output file info (stop/overwrite if this subj&session already collected)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
res_fold=['bhv_results_E2/', subjid, '/'];
%dropb_fold=['~/Dropbox/RDM_behavioral/'];
%res_fold=[dropb_fold, 'bhv_results_E2/', subjid, '/'];
[jnk1, jnk2]=mkdir(res_fold);

for run_number=1:2
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('Preference', 'SkipSyncTests', 1)%oldEnableFlag   

try 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%% PsychToolbox setup %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %shorten the internal calibrations and display tests (max 5s) during debugging
    %restore settings (0 - no skip) at end of script
    %oldEnableFlag = Screen('Preference', 'SkipSyncTests', 1)
    %need this for some of the os x things?
    AssertOpenGL;
    %choose the display screen (needed if multiple monitors attached)
    screenNumber = max(Screen('Screens'));
    %run code to find the device number for a wired apple keyboard
    kbDev=local_findKeyboard;
    %need to call Gamepad<-PsychHID once to get the slow initial loading of 
    %the mex file out of the way...
    
    
    
   %used test_keys script to find key ids
    esc_key = 41;%KbName('escape'); %this key kills script during the experiment
    g_key=10; %'g' key
    enter_key = 40;%KbName('enter') gives diff number ?!; used to move on past instructions
    key1=30; key2=31; key3=32; key4=33; key5=34; key6=35; key7=36;%%keys:1 thru 7
    
    
    
    black=BlackIndex(screenNumber); %bkgd color for the inst will be black
    white=WhiteIndex(screenNumber); %bkgd color for experiment will be white
    w=Screen('OpenWindow', screenNumber);
    nrSamples=10; [monitorFlipInterval nrValidSamples stddev] =Screen('GetFlipInterval', w, nrSamples);
    slack = monitorFlipInterval/2 %divide by 2 (or only for OpenWindow stereomode=1?;
    
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
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%% load images / info %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    
    %%design fixation crosses / prompt
    [y, x]=meshgrid(1:30,1:30);
    x=(x>12)&(x<17); y=(y>12)&(y<17);
    fixation_dark=double(x | y)*80;    
    fixation_grey=double(x | y)*153;

    
    %%load images and corr resp           
     im_mat_fl=['stims/stim_mat.mat'];
     load(im_mat_fl, 'im_mat')
                    
    
    %read trial order, position (left/right)
    fl=['stims_ord_E2/', subjid, '_ord_mat.txt'];
    ord_id_mat=dlmread(fl);
    ord_gend_mat=single(ord_id_mat>60)+1;% 1-male, 2-female
    
    lr_ind=randperm(240)>120;%repmat([0; 1], [120 1]);

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%% parameters %%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
       

    totalEvents_perRun=240;
    
    tmp=rand(240, 1); tmp=tmp*0.8; tmp=tmp+0.2;
    fixationTime_vect=[1; tmp];%%min: 0.2, max: 1 
    stimPresLength_max = 4.0;    
    respTime_max=2.0;%0.4
    
    instructionsToUse=1;
    local_doInstructions(w, instructionsToUse, black, enter_key, esc_key)
       
    for run_number=1:2
        
        ord_id_vect=ord_id_mat(:, run_number);
        ord_gend_vect=ord_gend_mat(:, run_number);
        
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
        fprintf(fid,'%s %s \n','Psychtoolbox version ', PTversion(1:83));
        fprintf(fid,'%s %s %s %s %s %s \n','Subjid:', subjid);
        fprintf(fid,'%s %i \n','Run Number:', run_number);    
        fprintf(fid,'%s \n','<><><><><><><><>');   
        fprintf(fid,'%s \n','Columns info in data file:');
        fprintf(fid,'%s \n','1. display side (left 1/right 0) 2. # indvd  3. # gend ');
        fprintf(fid,'%s \n','4. response (masc - 1 :: fem - 7) 5. RT ');
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
    
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%% main loop %%%%%%%%%%%%%%%%%%% 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        for trial_k=1:240
               

                trial_id_code=ord_id_vect(trial_k, 1)
                trial_gend_code=ord_gend_vect(trial_k, 1)

                im=im_mat(:,:,:, trial_id_code);
                if lr_ind(trial_k)                
                    stim=cat(2, im, zeros(size(im, 1), size(im, 2)*2, 3));
                else stim=cat(2, zeros(size(im, 1), size(im, 2)*2, 3), im);
                end
                    
                    
                Screen('PutImage', w, stim); % ready image


                WaitSecs('UntilTime', stimStartTime); % interval       
                Screen('Flip', w); % display 
                stimStartTime_act=GetSecs;

                Screen('PutImage', w, fixation_grey);


                keyCodes(1:256) = 0;
                
                
                
                %%% button press response or stim display expires
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                while sum(double(keyCodes([key1 key2 key3 key4 key5 key6 key7 g_key])))==0 && (GetSecs < stimEndTime_max)                                
                   [keyIsDown, secs, keyCodes, deltaSecs] = KbCheck;           
                   WaitSecs(0.01);
                end
                stimEndTime_act=GetSecs;

                stimTime_act=stimEndTime_act-stimStartTime_act;
                RT=stimTime_act;

           
                Screen('Flip', w); 


                %%% button press after stim display expires
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if sum(double(keyCodes([key1 key2 key3 key4 key5 key6 key7 g_key])))==0
                    while sum(double(keyCodes([key1 key2 key3 key4 key5 key6 key7 g_key])))==0 && (GetSecs < respEndTime)
                       [keyIsDown, secs, keyCodes, deltaSecs] = KbCheck;
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
                    if sum(double(keyCodes([key1 key2 key3 key4 key5 key6 key7])))>0 % if key pressed?
                        resp=find(keyCodes([key1 key2 key3 key4 key5 key6 key7]), 1, 'first') % ?
                        RT_act=RT;
                    else resp=NaN; res=NaN; RT_act=NaN;
                    end
                    
                    %store results for stimuli, append to file
                    res_vect=[lr_ind(trial_k) trial_id_code ord_gend_vect(trial_k, 1) resp RT_act  ]
                    
                    dlmwrite(resfile_nm, res_vect, '-append') % analysis file           
                    fprintf(fid,'%02.3f %02.3f %02.3f \n', stimStartTime_rec, stimEndTime_rec, RT); % info file



                else ShowCursor;
                     Screen('CloseAll');
                     error('User interrupted the trial by pressing escape...');
                end

        end
    
    
        % run preliminary analysis on this trial                
        trial_k=trial_k
        if trial_k~=240 %if debugging, use some random test values
            resp_std='DEBUG_VALUE'; RT_mn='DEBUG_VALUE'; consist='DEBUG_VALUE';
        else 
            [resp_std, RT_mn, consist]=anl_acc_consist_GC_E2({resfile_nm})
        end

        fprintf(fid,'%s \n','<><><><><><><><>');
        %fprintf(fid,'%s %02.2f %s %02.2f %s %02.2f \n','Rank: ', rank, '   Male acc: ', m_acc, '   Fem acc: ', f_acc);
        fprintf(fid,'%s %02.2f \n','Response (Std deviation): ', resp_std);
        fprintf(fid,'%s %02.2f \n','RT (mean): ', RT_mn);
        fprintf(fid,'%s %02.2f \n','Consistency: ', consist);
        fprintf(fid,'%s \n','<><><><><><><><>');
        fprintf(fid,'%s %s \n','End:', datestr(now));         
        fclose(fid);


        local_doEndScreen(w, black, run_number, esc_key, resp_std, RT_mn, consist)
        
        
    end
    
    ShowCursor;
    Screen('CloseAll');
    
catch exception1
    
    ShowCursor;
    Screen('CloseAll');

    throw(exception1);
end

% source_fold=['bhv_results/', subjid, '/']
% targ_fold=['~/Dropbox/Adrian_RDM_behavioral/bhv_results/', subjid, '/']
% [status, message] = copyfile(source_fold, targ_fold)
    



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display instructions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_doInstructions(window, instNum, bkgdColor, enter_key, esc_key)

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
                Screen('DrawText', window, 'In this experiment you will be presented with male  and female faces.', inst_horzpos, top_vertpos+inst_vertpos, inst_color); 
                Screen('DrawText', window, 'Your task is to rate a face, on a scale from 1 to 7 by how masculine or feminine it is.', inst_horzpos, top_vertpos+inst_vertpos*2, inst_color);
                Screen('DrawText', window, 'If the face is very masculine, press the 1 key.', inst_horzpos, top_vertpos+inst_vertpos*3, inst_color);
                Screen('DrawText', window, 'If the face is very feminine, press the 7 key.', inst_horzpos, top_vertpos+inst_vertpos*4, inst_color);
                Screen('DrawText', window, 'Please, during this task, try to utilize the entire scale from 1 to 7 when rating.', inst_horzpos, top_vertpos+inst_vertpos*5, inst_color);
                Screen('DrawText', window, 'Also, try to respond in a timely manner.', inst_horzpos, top_vertpos+inst_vertpos*6, inst_color);              
                Screen('DrawText', window, 'Press enter to move on.', inst_horzpos, top_vertpos+inst_vertpos*8, inst_color);

                
                Screen('Flip', window);
            otherwise
                Screen('DrawText', window, 'No instructions found for this section -- sorry!', inst_horzpos, top_vertpos+inst_vertpos, inst_color);
                Screen('Flip', window);
end

keyCodes(1:256) = 0;
while sum(double(keyCodes([enter_key esc_key])))==0
    [keyIsDown, secs, keyCodes, deltaSecs] = KbCheck;
    
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
function local_doEndScreen(window, bkgdColor, run_number, esc_key, resp_std, RT_mn, consist)%inputDev, , enter_key

% if run_number==1 || run_number==3
    call_exp=1;
% elseif run_number==5
%     call_exp=2;
% else call_exp=0;
% end
if run_number==5
   call_exp=2;
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

Screen('DrawText', window, ['End of run ', num2str(run_number), ' (out of 2).'], inst_horzpos, top_vertpos+inst_vertpos, inst_color);
    
resp_txt=sprintf('Standard deviation of responses is %02.2f%', resp_std, '%')
Screen('DrawText', window, resp_txt, inst_horzpos, top_vertpos+inst_vertpos*3);

RT_txt=sprintf('Mean reaction time is %02.2f', RT_mn)
Screen('DrawText', window, RT_txt, inst_horzpos, top_vertpos+inst_vertpos*4);

consist_txt=sprintf('Consistency is %02.2f', consist)
Screen('DrawText', window, consist_txt, inst_horzpos, top_vertpos+inst_vertpos*5);



Screen('TextColor',window, [255 255 255]);
if call_exp==1
    Screen('DrawText', window, 'Take a short break if needed. Please call the experimenter to continue!', inst_horzpos, top_vertpos+inst_vertpos*7);
elseif call_exp==2
    Screen('DrawText', window, 'You are finished. Please call the experimenter!', inst_horzpos, top_vertpos+inst_vertpos*7);
%else Screen('DrawText', window, 'Take a short break if needed. Then press ''Enter'' to continue!', inst_horzpos, top_vertpos+inst_vertpos*7);
end
Screen('Flip', window);

keyCodes(1:256) = 0;

if call_exp>0
    while ~keyCodes(esc_key)
        [keyIsDown, secs, keyCodes, deltaSecs] = KbCheck;
    end
else while ~keyCodes(enter_key)
        [keyIsDown, secs, keyCodes, deltaSecs] = KbCheck;
    end
end
% ShowCursor;
% Screen('CloseAll');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Code to find keyboard %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function kbDev=local_findKeyboard
% Parse through the list of input devices and get the numbers for any
% attached keyboards. Need to do this because the actual number of any
% given keyboard varies depending on the other input devices that are
% attached and when they were attached. For some reason, my Logitech
% Wireless mouse doesn't show up at all in the device list OR, even
% worse, shows up, but also seems to create a "ghost" entry for a
% Logitech keyboard, usually as the first keyboard in the list!!!
%
% Some suggestions about this:
% 1. Don't ever use a Logitech mouse while try to run PTB.
% 2. Check if the manufacturer is Logitech and, if so, reject it
% 3. Create a list of all keyboards with some precedence for Apple
%    keyboards that are not connected via bluetooth
%
% I implement #3 below, it is ugly, but at this point in the
% experiment, time ain't so critical, just have to calculate this once
% (unless some perverse person plugs in or removes an input device
% during the experiment!)

nDevs = PsychHID('NumDevices');
devices = PsychHID('Devices');
kbDev = 0;

% search for a hard connected apple keyboard
for dv = 1:nDevs,
    if (strcmp(devices(dv).usageName, 'Keyboard') & strcmp(devices(dv).manufacturer, 'Apple') & ~strcmp(devices(dv).transport, 'Bluetooth'))
        kbDev = dv;
        disp('Found wired apple keyboard.');
        break;
    end
end

% search for any apple keyboard
if (~kbDev)
    for dv = 1:nDevs,
        if (strcmp(devices(dv).usageName, 'Keyboard') & strcmp(devices(dv).manufacturer, 'Apple'))
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

