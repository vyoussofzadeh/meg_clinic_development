function [Events, AcqPars] = parse_aveFile_events(aveFile)
% parse_aveFile_events: reads the average file and extracts Event info and
% acquisition parameters
%
% USAGE:    [Events, AcqPars] = parse_aveFile_events(aveFile)
%
% INPUT:    aveFile = average file containing event acquisition info
%
% OUTPUT:   Events = Structure containing event information
%           AcqPars = Structure containing acquisition parameters
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB JULY-2010    Creation
% -------------------------------------------------------------------------
% Read the ave file and split the strings
c=fiff_read_evoked(aveFile);
buffer = c.info.acq_pars;
s = regexp(buffer,'\s','split');

t = strcmp(s, 'ERFncateg');
totalCategories = str2double(s(find(t) + 1));

% Loop through the categories and get event info.
for n=1:totalCategories
    % For the first 10 categories, include '0' in the parameter name before
    % the category number
    if n < 10
        % Category Comment
        t = strcmp(s, strcat('ERFcatComment0',int2str(n)));
        label = find(t);
        Events(n).catComment = char(s(label+1));
        
        % Category Displayed during acq
        t = strcmp(s, strcat('ERFcatDisplay0',int2str(n)));
        label = find(t);
        Events(n).catDisplay = str2double(s(label+1));
        
        % Online average end time
        t = strcmp(s, strcat('ERFcatEnd0',int2str(n)));
        label = find(t);
        Events(n).catEnd = str2double(s(label+1));
        
        % Category number
        t = strcmp(s, strcat('ERFcatEvent0',int2str(n)));
        label = find(t);
        Events(n).catEvent = str2double(s(label+1));
        
        % Number of events averaged in the category
        t = strcmp(s, strcat('ERFcatNave0',int2str(n)));
        label = find(t);
        Events(n).catNave = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFcatReqEvent0',int2str(n)));
        label = find(t);
        Events(n).catReqEvent = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFcatReqWhen0',int2str(n)));
        label = find(t);
        Events(n).catReqWhen = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFcatReqWithin0',int2str(n)));
        label = find(t);
        Events(n).catReqWithin = str2double(s(label+1));
        
        % Online average Start time
        t = strcmp(s, strcat('ERFcatStart0',int2str(n)));
        label = find(t);
        Events(n).catStart = str2double(s(label+1));
        
        % Category state (on or off)
        t = strcmp(s, strcat('ERFcatState0',int2str(n)));
        label = find(t);
        Events(n).catState = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFcatSubAve0',int2str(n)));
        label = find(t);
        Events(n).catSubAve = str2double(s(label+1));
        
        % Event channel (STI101 or STI102)
        t = strcmp(s, strcat('ERFeventChannel0',int2str(n)));
        label = find(t);
        Events(n).eventChannel = char(s(label+1));
        
        % Event Comment
        t = strcmp(s, strcat('ERFeventComment0',int2str(n)));
        label = find(t);
        Events(n).cateventComment = char(s(label+1));
        
        t = strcmp(s, strcat('ERFeventDelay0',int2str(n)));
        label = find(t);
        Events(n).eventDelay = str2double(s(label+1));
        
        % Event Name
        t = strcmp(s, strcat('ERFeventName0',int2str(n)));
        label = find(t);
        Events(n).eventName = char(s(label+1));
        
        % Event value bits
        t = strcmp(s, strcat('ERFeventNewBits0',int2str(n)));
        label = find(t);
        Events(n).eventNewBits = str2double(s(label+1));
        
        % Event mask bits
        t = strcmp(s, strcat('ERFeventNewMask0',int2str(n)));
        label = find(t);
        Events(n).eventNewMask = str2double(s(label+1));
        
        % Event old value bits (reference, typically 0, but can be 49152
        % when using the finger response pads)
        t = strcmp(s, strcat('ERFeventOldBits0',int2str(n)));
        label = find(t);
        Events(n).eventOldBits = str2double(s(label+1));
        
        % Event old mask bits
        t = strcmp(s, strcat('ERFeventOldMask0',int2str(n)));
        label = find(t);
        Events(n).eventOldMask = str2double(s(label+1));
    
        % If there are more than 9 events, search parameters names without
        % adding a '0'
    else
        t = strcmp(s, strcat('ERFcatComment',int2str(n)));
        label = find(t);
        Events(n).catComment = char(s(label+1));
        
        t = strcmp(s, strcat('ERFcatDisplay',int2str(n)));
        label = find(t);
        Events(n).catDisplay = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFcatEnd',int2str(n)));
        label = find(t);
        Events(n).catEnd = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFcatEvent',int2str(n)));
        label = find(t);
        Events(n).catEvent = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFcatNave',int2str(n)));
        label = find(t);
        Events(n).catNave = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFcatReqEvent',int2str(n)));
        label = find(t);
        Events(n).catReqEvent = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFcatReqWhen',int2str(n)));
        label = find(t);
        Events(n).catReqWhen = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFcatReqWithin',int2str(n)));
        label = find(t);
        Events(n).catReqWithin = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFcatStart',int2str(n)));
        label = find(t);
        Events(n).catStart = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFcatState',int2str(n)));
        label = find(t);
        Events(n).catState = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFcatSubAve',int2str(n)));
        label = find(t);
        Events(n).catSubAve = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFeventChannel',int2str(n)));
        label = find(t);
        Events(n).eventChannel = char(s(label+1));
        
        t = strcmp(s, strcat('ERFeventComment',int2str(n)));
        label = find(t);
        Events(n).cateventComment = char(s(label+1));
        
        t = strcmp(s, strcat('ERFeventDelay',int2str(n)));
        label = find(t);
        Events(n).eventDelay = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFeventName',int2str(n)));
        label = find(t);
        Events(n).eventName = char(s(label+1));
        
        t = strcmp(s, strcat('ERFeventNewBits',int2str(n)));
        label = find(t);
        Events(n).eventNewBits = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFeventNewMask',int2str(n)));
        label = find(t);
        Events(n).eventNewMask = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFeventOldBits',int2str(n)));
        label = find(t);
        Events(n).eventOldBits = str2double(s(label+1));
        
        t = strcmp(s, strcat('ERFeventOldMask',int2str(n)));
        label = find(t);
        Events(n).eventOldMask = str2double(s(label+1));
    end 
end

% Acquisition parameters (rejection is turned off by default for now)
AcqPars.stimIgnore = 0;
AcqPars.ecgReject = -1;
AcqPars.eegReject = -1;
AcqPars.eogReject = -1;
AcqPars.eegFlat = 0;
AcqPars.ecgFlat = 0;
AcqPars.eogFlat = 0;
AcqPars.magReject = -1;
AcqPars.gradReject = -1;
% Number of categories that are turned on
AcqPars.nCategories = sum([Events.catState]);

t = strcmp(s, strcat('ERFtriggerMap'));
label = find(t);
AcqPars.triggerMap = s(label+1);
    