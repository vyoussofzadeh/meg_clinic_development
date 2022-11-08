function process_xfit_input(varargin)
% process_xfit_input: callback function from MEG-Clinic, Create Command File
%
% USAGE:    set(cfitButton, 'ActionPerformedCallback', {@process_xfit_input, mc});
%           process_xfit_input(mc)
%
% INPUT:    mc = MEG-Clinic instance
%
% Author: Elizabeth Bock, 2009
% --------------------------- Script History ------------------------------
% EB 27-AUG-2009    Creation - adapted from Sophie Chen, xfit_input()
% EB 26-MAY-2010    Updates for callback
% EB 28-MAY-2010    Added time shift when creating new chunked file for
% events
% -------------------------------------------------------------------------

if nargin > 2
    % This is the callback (obj = varargin{1}, event = varargin{2})
    mc = varargin{3};
else
    % This is direct usage
    mc = varargin{1};
end

% Creates a command file for dipole fitting according to the configuration
% parameters in CfitConfig.java

mc.setMessage(GUI.Config.M_MAKE_XFIT_COMMAND);
%% Get Configuration
% Get configs from MEG-Clinic 
cfitConfig = DipoleFit.CfitConfig;
% Init structure
sXfit = get_xfitConfigStruct();
% Populate structure from user inputs
sXfit.fileType = char(cfitConfig.TYPE);              % raw or evoked
sXfit.fileName = char(cfitConfig.NAME);              % .fif file
sXfit.pathName = char(cfitConfig.PATH);              % directory where fif file is located
sXfit.xfitPath = strcat(sXfit.pathName,'/xfit');   % directory to store outputs of dipole fitting process
% Make xfit directory if it does not exist
if ~(exist(sXfit.xfitPath, 'dir') == 7)
    mkdir(sXfit.xfitPath)
end

sXfit.useChSubsets = cfitConfig.CH_SUBSET;          % Use channel subsets defined in /HOME/.meg_analysis/xfit_selections
sXfit.useGlobalFit = cfitConfig.GLOBAL_SUBSET;  % Include a global (no subset) fit along with the subsets
sXfit.isRawEventsDefined = cfitConfig.RAW_TIME_WIN;    % Run dipole fitting in a specific time window surrounding defined events
if sXfit.isRawEventsDefined
    sXfit.rawEventFile = char(cfitConfig.EVE_FILE);
    sXfit.rawEventNumber = char(cfitConfig.EVE_NUM);        % Event number from event file
    sXfit.rawEventTimeWin = [str2double(char(cfitConfig.EVE_START)), str2double(char(cfitConfig.EVE_END))];       % [start, end] Offset from event to start and end epoch
end
sXfit.rawChunkLength = '10'; % Default 10 seconds

sXfit.useFilter = cfitConfig.FILTER;
if sXfit.useFilter
    sXfit.filterFreq = [str2double(char(cfitConfig.LPF)), str2double(char(cfitConfig.HPF))];
end

sXfit.isEvokedTimeDefined = cfitConfig.EVOKED_TIME_WIN;   % Run dipole fitting in a specific time window in averaged epoch
if sXfit.isEvokedTimeDefined
    sXfit.evokedTimeWin = [str2double(char(cfitConfig.WIN_START)), str2double(char(cfitConfig.WIN_END))]; % [start, end] Offset from event to start and end time window
end

sXfit.useEvokedBaseline = cfitConfig.BASELINE;
if sXfit.useEvokedBaseline
    sXfit.evokedBaselineTime = [str2double(char(cfitConfig.BASE_START)), str2double(char(cfitConfig.BASE_END))]; % [start, end]
end

sXfit.fitInterval = char(cfitConfig.FIT_INTERVAL); % Interval for fitting dipoles

filePath = fullfile(sXfit.pathName, sXfit.fileName);
runNumber = sXfit.fileName(1:5);

%% get the coordinates of the origin of the sphere in the head coordinate system
[ctr_head_coord,rad_head_coord]=nsi_fif2ctr(filePath);
sXfit.centerHeadCoord = ctr_head_coord*1000;

switch lower(sXfit.fileType)

% ----------- CASE 1 : RAW DATA ------------------------------------------
    case 'raw'

        clear global FIFF

        % Get the header information
        sXfit.fiffsetup = fiff_setup_read_raw(filePath);        

        % Get the data structure
        p = fileparts(which(mfilename));
        load([p '/evoked_template.mat'])
        sXfit.data = evokedTemplate;
        %sXfit.data = fiff_read_evoked_all('left_median_tibial_ave_nosss.fif');

        % Make output file names
        if sXfit.useChSubsets && sXfit.useGlobalFit && sXfit.isRawEventsDefined
            sXfit.epochDataFile = strcat(sXfit.xfitPath,'/',runNumber,'_event',sXfit.rawEventNumber,'_chunked_raw.fif');
            sXfit.commandFile = strcat(sXfit.xfitPath,'/',runNumber,'_event',sXfit.rawEventNumber,'_5subsets(L,R,Post,Ant,GLBL).cfit');
            sXfit.rawEventNumber = str2double(sXfit.rawEventNumber);

        elseif sXfit.useChSubsets && ~sXfit.useGlobalFit && sXfit.isRawEventsDefined
            sXfit.epochDataFile = strcat(sXfit.xfitPath,'/',runNumber,'_event',sXfit.rawEventNumber,'_chunked_raw.fif');
            sXfit.commandFile = strcat(sXfit.xfitPath,'/',runNumber,'_event',sXfit.rawEventNumber,'_4subsets(L,R,Post,Ant).cfit');
            sXfit.rawEventNumber = str2double(sXfit.rawEventNumber);

        elseif sXfit.useChSubsets && sXfit.useGlobalFit && ~sXfit.isRawEventsDefined   
            sXfit.epochDataFile = strcat(sXfit.xfitPath,'/',runNumber, '_chunked_',sXfit.rawChunkLength, 's_chunked_raw.fif');
            sXfit.commandFile = strcat(sXfit.xfitPath,'/',runNumber,'_noEvents_5subsets(L,R,Post,Ant,GLBL).cfit');
            sXfit.rawChunkLength = str2double(sXfit.rawChunkLength);

        elseif sXfit.useChSubsets && ~sXfit.useGlobalFit && ~sXfit.isRawEventsDefined   
            sXfit.epochDataFile = strcat(sXfit.xfitPath,'/',runNumber, '_chunked_',sXfit.rawChunkLength, 's_chunked_raw.fif');
            sXfit.commandFile = strcat(sXfit.xfitPath,'/',runNumber,'_noEvents_4subsets(L,R,Post,Ant).cfit');
            sXfit.rawChunkLength = str2double(sXfit.rawChunkLength);

        elseif ~sXfit.useChSubsets && sXfit.isRawEventsDefined
            sXfit.epochDataFile = strcat(sXfit.xfitPath,'/',runNumber,'_event',sXfit.rawEventNumber,'_chunked_raw.fif');
            sXfit.commandFile = strcat(sXfit.xfitPath,'/',runNumber,'_event',sXfit.rawEventNumber,'_nosubsets(GLBL_only).cfit');
            sXfit.rawEventNumber = str2double(sXfit.rawEventNumber);

        elseif ~sXfit.useChSubsets && ~sXfit.isRawEventsDefined
            sXfit.epochDataFile = strcat(sXfit.xfitPath,'/',runNumber, '_chunked_',sXfit.rawChunkLength, 's_chunked_raw.fif');
            sXfit.commandFile = strcat(sXfit.xfitPath,'/',runNumber,'_noEvents_nosubsets(GLBL_only).cfit');
            sXfit.rawChunkLength = str2double(sXfit.rawChunkLength);
        end

        sXfit.iEventType = 1; % only one event type
        writeCommandFile(sXfit);

% ----------- CASE 2 : Evoked File ----------------------------------------

    case 'evoked'

        clear global FIFF
        sXfit.epochDataFile = filePath;

        % get the information of the header in an average sss.fif from the data
        sXfit.data = fiff_read_evoked_all(filePath);

        % Make output file names
        if sXfit.useChSubsets && sXfit.useGlobalFit&& sXfit.isEvokedTimeDefined
            sXfit.commandFile = strcat(sXfit.xfitPath,'/',runNumber,'_timeWin_5subsets(L,R,Post,Ant,GLBL).cfit');

        elseif sXfit.useChSubsets && ~sXfit.useGlobalFit && sXfit.isEvokedTimeDefined
            sXfit.commandFile = strcat(sXfit.xfitPath,'/',runNumber,'_timeWin_4subsets(L,R,Post,Ant).cfit');

        elseif sXfit.useChSubsets && sXfit.useGlobalFit&& ~sXfit.isEvokedTimeDefined
            sXfit.commandFile = strcat(sXfit.xfitPath,'/',runNumber,'_notimeWin_5subsets(L,R,Post,Ant,GLBL).cfit');

        elseif sXfit.useChSubsets && ~sXfit.useGlobalFit&& ~sXfit.isEvokedTimeDefined
            sXfit.commandFile = strcat(sXfit.xfitPath,'/',runNumber,'_notimeWin_4subsets(L,R,Post,Ant).cfit');

        elseif ~sXfit.useChSubsets && sXfit.isEvokedTimeDefined
            sXfit.commandFile = strcat(sXfit.xfitPath,'/',runNumber,'_timeWin_nosubsets(GLBL_only).cfit');

        elseif ~sXfit.useChSubsets && ~sXfit.isEvokedTimeDefined
            sXfit.commandFile = strcat(sXfit.xfitPath,'/',runNumber,'_notimeWin_nosubsets(GLBL_only).cfit');
        end
        writeCommandFile(sXfit);
    otherwise 
        disp('wrong file type') 
end
mc.setMessage(GUI.Config.M_XFIT_COMMAND_WRITTEN); 
mc.refreshSelectedWorkflow(GUI.DataSet.currentWorkflow);
updateButton = mc.getCalcDipButton();
updateButton.doClick();
end

%% Write command file
function writeCommandFile(sXfit)
% Open command file
fid = fopen(sXfit.commandFile,'w');

% Writing origin head in the command file
fprintf(fid,'%s','origin head ');
fprintf(fid,'%i\t',sXfit.centerHeadCoord(1));
fprintf(fid,'%i\t',sXfit.centerHeadCoord(2));
fprintf(fid,'%i\t\n',sXfit.centerHeadCoord(3));
fprintf(fid,'%s\n','fixorigin');
fprintf(fid,'%s\n','dipclear ');

% Filtering the data
if sXfit.useFilter
    fprintf(fid,'%s\t','filter '); 
    fprintf(fid,'%s\t','lowpass '); 
    fprintf(fid,'%i\t',sXfit.filterFreq(1)); 
    fprintf(fid,'%s\t','highpass '); 
    fprintf(fid,'%i\t\n',sXfit.filterFreq(2)); 
else
    fprintf(fid,'%s\t\n','nofilter ');
end

% Set baseline
if sXfit.useEvokedBaseline
    fprintf(fid,'%s\t','baseline '); 
    fprintf(fid,'%i\t',sXfit.evokedBaselineTime(1)); 
    fprintf(fid,'%i\t\n',sXfit.evokedBaselineTime(2));
    fprintf(fid,'%s\n','noise baseline');
else
    % This is default for raw
    fprintf(fid,'%s\n','baseline off');
    if strcmp(sXfit.fileType, 'evoked')
        % This is default for evoked
        fprintf(fid,'%s\n','noise constant 5 20 1');
    end
end

% Get the sampling frequency
if ~isempty(sXfit.fiffsetup)
    sampFreq = floor(sXfit.fiffsetup.info.sfreq);
end

% Get the data.evoked structure
data = sXfit.data;
epochTime = [];

% Determine the number of epochs
if sXfit.isRawEventsDefined
    if strfind(sXfit.rawEventFile,'.fif')
        events = double(mne_read_events(sXfit.rawEventFile));
    else
        events = load(sXfit.rawEventFile);
    end

    % if the event file is an annotation file, add the dummy event and calculate 
    % the offset time to be compatible with mne event files
    if strfind(sXfit.rawEventFile,'-annot')
        dummy = [double(sXfit.fiffsetup.first_samp) double(sXfit.fiffsetup.first_samp)/sXfit.fiffsetup.info.sfreq 0 0];
        times = events(:,1)/sampFreq;
        temp = [events(:,1) times events(:,2) events(:,3)];
        all_events = [dummy;temp];
    else
        all_events = events;
    end

    % ----------- Select event type from event file ---------------------------
    event_type = sXfit.rawEventNumber;
    type_indices = find(all_events(:,size(all_events,2)) == event_type);
    type_events = all_events(type_indices,:);

    epochWin = ceil((sXfit.rawEventTimeWin/1000)*sampFreq); % ->seconds ->samples
    nSamples = diff(epochWin);
    raw_startSamples = type_events(:,1)+epochWin(1);
    nEpochs = size(type_events,1);

elseif strcmp(sXfit.fileType, 'raw')
    nSamples = sampFreq * sXfit.rawChunkLength; % seconds ->samples
    epochWin = [0 nSamples]; % in samples
    raw_startSamples = sXfit.fiffsetup.first_samp:nSamples:sXfit.fiffsetup.last_samp-nSamples;
    nEpochs = length(raw_startSamples);

elseif sXfit.isEvokedTimeDefined
    nSamples = floor(diff(sXfit.evokedTimeWin));
    epochTime = sXfit.evokedTimeWin; % in milliseconds
    nEpochs = size(data.evoked,2);
    
elseif strcmp(sXfit.fileType, 'evoked')
    nEpochs = size(data.evoked,2);
    nSamples = size(sXfit.data.evoked(1,1).times, 2);
    epochTime = [sXfit.data.evoked(1,1).times(1,1)*1000  sXfit.data.evoked(1,1).times(1,nSamples)*1000];

else
    error('cannot determine number of epochs to process')
end

% If less epochs than originally available in evoked file, trim out evoked
% data structure for subsequent use 
if nEpochs < length(data.evoked)
    data.evoked = data.evoked(1:nEpochs);
end

    
    % For all epochs
for i = 1:nEpochs

    %writting in the commands file the sample to be loaded
    fprintf(fid,'%s','load ');
    fprintf(fid,'%s\t',sXfit.epochDataFile); 
    fprintf(fid,'%i\t\n',i);
    %autoscale
    fprintf(fid,'%s\n','autoscale');

    if strcmp(sXfit.fileType, 'raw')
        data.evoked(1,i)=data.evoked(1,1);
        
        % Get the info struct from raw file
        data.info = sXfit.fiffsetup.info;
        
        % Get raw data
        startRaw = raw_startSamples(i);
        endRaw = raw_startSamples(i)+nSamples;
        if endRaw > sXfit.fiffsetup.last_samp
            break;
        end
        [data_,times_] = fiff_read_raw_segment(sXfit.fiffsetup,startRaw,endRaw);
        data.evoked(1,i).epochs=data_;

        % Update times data for the samples (in seconds)
        sampPeriod = 1/sampFreq;
        data.evoked(1,i).times = epochWin(1)/sampFreq:sampPeriod:epochWin(2)/sampFreq;
        
        % Save first and last samples
        data.evoked(1,i).first = epochWin(1);
        data.evoked(1,i).last = epochWin(1)+nSamples;
        
        % Get start/end times for the fits
        epochTime = [data.evoked(1,i).times(1,1)*1000, data.evoked(1,i).times(1,nSamples+1)*1000]; % in milliseconds
        
        % Change the comment for every sample
        data.evoked(1,i).comment = ['sample # ' num2str(i) ' and start time of the sample is ' num2str(epochTime(1))/1000 ' sec '];
    end
    
    if sXfit.useChSubsets
        for k=1:4
            %using or not a file which select a part of the channels : this
            %file have to be loaded for every sample
            channel_file_name = ['Left sensors','Right sensors','Posterior sensors', 'Anterior sensors'];
            if (k==1) channel_select_file_name = channel_file_name(1:12); end
            if (k==2) channel_select_file_name = channel_file_name(13:25); end
            if (k==3) channel_select_file_name = channel_file_name(26:42); end
            if (k==4) channel_select_file_name = channel_file_name(43:58); end

            %writing the subsets file name in the command file
            fprintf(fid,'%s\n','loadsel ');
            fprintf(fid,'%s','usesel ');
            fprintf(fid,'%s\t\n',channel_select_file_name);

            %writting in the file the command corresponding to the fitting of the
            %file
            fprintf(fid,'%s','fit ');
            fprintf(fid,'%4.3f\t',epochTime(1));
            fprintf(fid,'%4.3f\t',epochTime(2));
            fprintf(fid,'%s\t\n',sXfit.fitInterval);
        end
        % include a global fit if the user selected this option
        if sXfit.useGlobalFit
            fprintf(fid,'%s\n','clearsel ');
            fprintf(fid,'%s','fit ');
            fprintf(fid,'%4.3f\t',epochTime(1));
            fprintf(fid,'%4.3f\t',epochTime(2));
            fprintf(fid,'%s\t\n',sXfit.fitInterval);
        end
        
    else % This is the global fit...
        % Just write one fit
        fprintf(fid,'%s','fit ');
        fprintf(fid,'%4.3f\t',epochTime(1));
        fprintf(fid,'%4.3f\t',epochTime(2));
        fprintf(fid,'%s\t\n',sXfit.fitInterval);
    end

    % If this an evoked file, save the dipoles separate for each epoch
    if strcmp(sXfit.fileType,'evoked')
        [d,n,e] = fileparts(sXfit.commandFile);
        eveComment = sXfit.data.evoked(i).comment;
        save_file = ['dipsave ' d '/' n '_' eveComment];
        fprintf(fid, '%s\n', save_file);
        fprintf(fid, '%s\n', 'dipclear');
        fprintf(fid, '%s\n\n', 'dipclear');
    end
end

% if thsi is a raw file, save the data epochs to a new chunked file
if strcmp(sXfit.fileType, 'raw')
    % Write the chunked file
    disp('Writing the chunked data file...')
    fiff_write_evoked(sXfit.epochDataFile,data);

    % ------------- save a binary version of all dipole information -------
    [d,n,e] = fileparts(sXfit.commandFile); % [d,n,e,v] = fileparts(sXfit.commandFile); % 08132013 JL removed the 4th field (version) of the output since it's no longer supported in 2012 matlab and can cause problem if not removed.
    save_file = ['dipsave ' d '/' n];
    fprintf(fid, '%s\n', save_file);

    
end
% closing commands file
fprintf(fid, '%s', 'exit');
fclose(fid);
disp('Closing command file')

end



