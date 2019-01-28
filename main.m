function main(subID)
clear all
close all


%PsychDebugWindowConfiguration

%Openin a Window 
whichScreen = 2; %allow to choose the display if there's more than one
[w, rect] = Screen( 'OpenWindow', whichScreen, 0);
Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%************************* Eyelink: start
dummymode=0;
if ~EyelinkInit(dummymode, 1)
    fprintf('Eyelink Init aborted.\n');
    Eyelink('Shutdown');
    return;
end

eye_used = -1;
el=EyelinkInitDefaults(w);
Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,PUPIL,AREA'); % open file to record data to
Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,FIXUPDATE,SACCADE'); % open file to record data to
edfFile=[subID '.edf'];
status= Eyelink('openfile',edfFile,1);
if status~= 0
   error('openfile error, status: ', status); 
end
Eyelink('trackersetup');
Eyelink('startrecording');
WaitSecs(1);
Eyelink('Message', 'SYNC  TIME');

disp('1');

if Eyelink( 'NewFloatSampleAvailable') > 0
    evt = Eyelink( 'NewestFloatSample');
    if eye_used ~= -1
        x = evt.gx(eye_used+1);
        y = evt.gy(eye_used+1);
    else % if we don't, first find eye that's   being tracked
        eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
%         if eye_used == el.BINOCULAR; % if both eyes are tracked
%             eye_used = el.RIGHT_EYE; % use left eye
%         end
    end
end

%start Trials
filename=strcat(subID, '.txt');
fileID = fopen(filename,'w');
D = '/home/brainlab/Documents/im';
S = dir(fullfile(D,'*')); % pattern to match filenames.
sqc=combnk(1:size(S),1)
sqc1=sqc(randperm(length(sqc)))
disp(numel(S));
for k = 1:size(sqc1)-2
    
    % Start Trial:start
    Eyelink('Message','TRIALID %d', k-2);
    mes=['start trial' num2str(k-2)];
    Eyelink('command','resord_status_messasge "%s"',mes);
    % Start Trial:end
    
    fixate(w, rect);
    Screen('Flip', w);
    WaitSecs(1);
    F = fullfile(D,S(sqc1(k)).name);
    disp(F);
    expression = '/home/brainlab/Documents/im/[a-z]+';
    matchStr = regexp(F,expression,'match')
    disp(matchStr);
    if ~isempty(matchStr)
        fprintf(fileID,'%s\n',F);
        smImSq = [0 0 400 400];
        [smallIm, xOffsetsigS, yOffsetsigS] = CenterRect(smImSq, rect);
        [img, ~, alpha] = imread(F);
        size(img)
        texture1 = Screen('MakeTexture', w, img);
        Screen('DrawTexture', w, texture1, [], smallIm);
        Screen('Flip', w);
        WaitSecs(5);
    end
    
    % End Trial:start
    Eyelink('Message','TRIAL_RESULT', k-2);
    Eyelink('Message','trial OK');
    % End Trial:end
end
% End Trials
fclose(fileID);
Eyelink('StopRecording');
Eyelink('CloseFile');
try
    fprintf('Receiving data file ''%s''\n', [subID '.edf'] );
    status=Eyelink('ReceiveFile', edfFile, pwd, 1);

    if status > 0
        fprintf('ReceiveFile status %d\n', status);
    end
    if 2==exist(edfFile, 'file')
        fprintf('Data file ''%s'' can be found in ''%s''\n', [subID '.edf'], pwd );
    end
catch rdf
    fprintf('Problem receiving data file ''%s''\n', [subID '.edf'] );
    rdf;
end
Eyelink('Shutdown');

%******************* Eyelink: end

sca;
Screen('CloseAll'); %closes the window
end