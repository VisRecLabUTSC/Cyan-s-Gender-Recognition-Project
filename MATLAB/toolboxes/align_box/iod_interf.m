                        function iod_interf(picdir)
%collects facial feature coordinates and writes them to txt file
%adapted for OS X
%3x-07.20.06

%clear all;

Screen('Preference', 'SkipSyncTests', 1)

str = {'Front view', 'Profile'};
[sel,ok] = listdlg('PromptString','Select view:',...
                'SelectionMode','single',...
                'ListSize',[150 100],...
                'Name', 'View',...
                'ListString',str);
            
if ok==0
    error('No view selected!')
end


npoints=5;
namesfile=[picdir, '/filenames.txt'];
coordfile=[picdir, '/coord.txt'];

delete(namesfile);
try
    AssertOpenGL;
    res1=640;%1050;%1600;%600;%480;%1024;%; 
    res2=1024;%1680;%2560;%640;%1280; %1280;  
    if nargin==0
        picdir=cd;
    end
    pics=dir(fullfile(picdir,'*.tif'));  
    
        
    nfl=size(pics,1) 
    for fl=1:nfl
        U{fl}=pics(fl).name        
    end
        
    escKey = KbName('escape');
    retKey = KbName('return');
    bsKey = KbName('delete');
    keyCodes(1:256) = false;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    Screens=Screen('Screens');
	ScreenNumber=max(Screens);
	
	[w, rect]=Screen('OpenWindow', ScreenNumber,0,[],32,2);
   	Screen('FillRect', w, [0, 0, 0, 255]);
	Screen('TextFont',w, 'Courier');
	Screen('TextSize',w, 20);
	Screen('TextStyle', w, 0);
	
            initls=10; 
            lf=0;
            ls = 50;
            black=BlackIndex(w);
            white=WhiteIndex(w);

            Screen('DrawText', w, 'DIRECTIONS: You will be presented with a sequence of faces.', ls+lf, initls+ls, white);
            Screen('DrawText', w, 'Your task will be to mark a number of features by clicking', ls+lf, initls+2*ls, white);
            Screen('DrawText', w, 'the left button of the mouse while having the pointer placed above them.', ls+lf, initls+3*ls, white);
            Screen('DrawText', w, 'Please, mark the  features in the following order: ', ls+lf, initls+4*ls, white);
            if sel==1
                Screen('DrawText', w, 'the center of the left eye, the center of the right eye,', ls+lf, initls+5*ls, white);
                Screen('DrawText', w, 'the tip of the nose, the left and right corners of the mouth.', ls+lf, initls+6*ls, white);
            else
                Screen('DrawText', w, 'the center of the eye, the tip of the nose', ls+lf, initls+5*ls, white);
                Screen('DrawText', w, 'the center of the ear, the corner of the mouth and the tip of the chin.', ls+lf, initls+6*ls, white);
            end
            Screen('DrawText', w, 'When finished with a stimulus press the return key to pass to the next one', ls+lf, initls+7*ls, white);
            Screen('DrawText', w, 'or delete to mark again the features of the same stimulus.', ls+lf, initls+8*ls, white);
            Screen('DrawText', w, 'Press any key to start!', ls+lf, initls+11*ls, white); 
            Screen('Flip',w);
            while keyCodes==0
                [keyPressed, secs, keyCodes] = KbCheck;
            end
    Screen('FillRect', w, [0, 0, 0, 255]);
    Screen('Flip', w);
    pause(1)  

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    dlmwrite(coordfile, []); %delete data from preexisting file 
    
    
    fid = fopen(namesfile, 'w+');
 
    
    fl=0;
    while ~keyCodes(escKey) & fl<nfl
        fl=fl+1;
         
        [stim, coord1, coord2]=makestim (res1, res2,(fullfile(picdir, U{fl})));
       
        textureIndex=Screen('MakeTexture',w , stim);        
        Screen('DrawTexture', w, textureIndex);
        Screen('Flip', w);
 
        
         
        for i=1:npoints
           
            buttons=[0 0 0];
            while buttons==[0 0 0]  
                %x=2
                [x,y,buttons] = GetMouse;  

            end
            
            coord(fl,(i-1)*2+1:i*2)=[y x];
            coord(fl,(i-1)*2+1:i*2)=coord(fl,(i-1)*2+1:i*2)-[coord1-1 coord2-1];
            %x=3
            while sum(buttons==[0 0 0])<3 %%ensures an interval btw 2 clicks  
                [xx,yy,buttons] = GetMouse;
            end
            %x=4
            x=x
            y=y
            stim(y-5:y+5, x-5:x+5,:)=ones(11,11,3)*255;
            textureIndex=Screen('MakeTexture',w , stim);        
            Screen('DrawTexture', w, textureIndex);
            Screen('Flip', w);
        end
         
        keyCodes(1:128) = false; 
       
        while sum(keyCodes==true)==0
            [keyPressed, secs, keyCodes] = KbCheck;
        end
        
                
        Screen('FillRect',w, black);   
        %xlswrite(xlsfile, {char(U{fl})}, 'Sheet1', strcat('A', num2str(fl)))
        %xlswrite(xlsfile, coord(fl,:), 'Sheet1', strcat('B', num2str(fl)))
        
        dlmwrite(coordfile, coord(fl,:),'-append'); 
        fprintf(fid, [U{fl}, '\n']);
        
        
        
        if keyCodes(bsKey) 
            fl=fl-1;
        end
                
        
    end
  
    
    
    fclose(fid)
    Screen('FillRect', w, white);
    Screen('CloseAll'); 
    
    
    clear all;
             
catch
    
    ShowCursor;
    Screen('CloseAll');
    rethrow(lasterror);
    clear all
     
end 

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [stim, coord1, coord2]=makestim (res1, res2, fpath)


    face=imread(fpath);
    face=face(1:min(res1-1, size(face,1)),1:min(res2-1, size(face,2)),:);
    szface=size(face); 
    
    
    
    
    
    
    
    coord1=round((res1-szface(1))/2);
    coord2=round((res2-szface(2))/2);
    if length(szface)==3
        stim=zeros(res1,res2,3)*255;
    else stim=zeros(res1,res2)*255;
    end

    stim(coord1:coord1+szface(1)-1, coord2:coord2+szface(2)-1,:)=face;

   