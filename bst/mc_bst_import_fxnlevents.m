function selectedStudies = mc_bst_import_fxnlevents(rawFiles, eventList)
% mc_bst_import_fxnlevents: imports the functional paradigm event epochs
% from the orig MEG raw data
%
% USAGE:    selectedStudies = mc_bst_import_fxnlevents(rawFiles, eventList)
%
% INPUT:    rawFiles = original MEG raw files
%           eventList = list of event types to import
%
% OUTPUT:   selectedStudies = study indices of the new studies created here
%
% Author: Elizabeth Bock, 2011
% --------------------------- Script History ------------------------------
% EB 12-JULY-2011    Creation
% -------------------------------------------------------------------------

selectedStudies = [];
for f = 1:length(rawFiles)

 % -----Get corresponding "study" name
    selectedFile = rawFiles{f};
    [path, fileName] = fileparts(selectedFile);
    sProtocol = bst_get('ProtocolInfo');
    studyDir = sProtocol.STUDIES;
    subjectName = char(GUI.DataSet.subject);
    [sSubject, iSubject] = bst_get('Subject',subjectName);
    subjectName = sSubject.Name;
    currentStudyName = fullfile(studyDir, subjectName, fileName, 'brainstormstudy.mat');
    % Check for raw segments already imported
    [sStudy, iStudy]=bst_get('Study', currentStudyName);   
    selectedStudies = [selectedStudies iStudy];
 % Get default structure for configuring import
    ImportOptions = db_template('ImportOptions');
    
    % -----Import events
    cnfgs = GUI.DataSet.currentSession;
    winStrt = str2double(char(cnfgs.getType(GUI.Session.FXNLIMPORTSTRT))); % Java uses zero indexing
    winStop = str2double(char(cnfgs.getType(GUI.Session.FXNLIMPORTSTOP))); % Java uses zero indexing
    baseStrt = str2double(char(cnfgs.getType(GUI.Session.FXNLBASESTRT))); % Java uses zero indexing
    baseStop = str2double(char(cnfgs.getType(GUI.Session.FXNLBASESTOP))); % Java uses zero indexing
    
    
    ImportOptions.ImportMode = 'Event';
    ImportOptions.UseEvents = 1;
    ImportOptions.EventsTimeRange = [winStrt, winStop];
    ImportOptions.UseSsp = 1; 
    ImportOptions.RemoveBaseline = 'time';
    ImportOptions.BaselineRange  = [baseStrt baseStop];
    ImportOptions.CreateConditions = 0;
    ImportOptions.DisplayMessages = 0;
    ImportOptions.ChannelAlign = 2;

    % Look for .eve file, if it exists, find events that have not
    % been imported.
    path = fileparts(selectedFile);
    files = dir([path '/*.eve']);
    iEvt = [];
    if ~isempty(files)        
        eveFile = fullfile(path,files(1).name);
        ImportOptions.EventsMode = eveFile;
        % Open FIF file, to get the events
        sFile = in_fopen_fif(selectedFile,ImportOptions);

        % find events from the eventList in the .eve file
        for i=1:length(eventList)
            dataIndices = [];
            label = '';
            ind = strfind({sFile.events.label}, eventList{i});
            eveInd = find(~cellfun(@isempty, ind));
            if eveInd 
                % this event exists in the annot file            
                if ~isempty(sStudy)
                    DataFiles = sStudy.Data;
                    % Filter results
                    x=regexp({DataFiles.FileName}, ['Event' '\w' eventList{1}]);
                    c=cellfun(@isempty, x);
                    dataIndices = find(c==0);
                end

                if isempty(dataIndices) && ~strcmp('Event #0', label) 
                    iEvt = [iEvt eveInd];
                end
            end
        end
        % Import the events that still need to be imported
        if ~isempty(iEvt)
            ImportOptions.events = sFile.events(iEvt);
            ImportOptions.AutoAnswer = 1;
        else
            continue;
        end
    else
        % Open FIF file, no eve file exists, so prompt the user to
        % input an events file
        sFile = in_fopen_fif(selectedFile);

        % Find if these events were already imported
        for i=1:length(eventList)
            dataIndices = [];
            label = '';
            ind = strfind({sFile.events.label}, eventList{i});
            eveInd = find(~cellfun(@isempty, ind));
            if eveInd 
                % this event exists in the annot file            
                if ~isempty(sStudy)
                    DataFiles = sStudy.Data;
                    % Filter results
                    x=regexp({DataFiles.FileName}, ['Event' '\w' eventList{1}]);
                    c=cellfun(@isempty, x);
                    dataIndices = find(c==0);
                end

                if isempty(dataIndices) && ~strcmp('Event #0', label) 
                    iEvt = [iEvt eveInd];
                end
            end
        end
        % Import the events that still need to be imported
        if ~isempty(iEvt)
            ImportOptions.events = sFile.events(iEvt);
            ImportOptions.AutoAnswer = 1;
        else
            return
        end
    end

    % Import recordings
    %import_data(sFile, 'FIF', iStudy, iSubject, ImportOptions);
    ChannelFile = bst_get('ChannelForStudy', iStudy);
    if ~isempty(ChannelFile)
        ChannelMat = in_bst_channel(file_fullpath(ChannelFile.FileName));
        import_data(sFile, ChannelMat, 'FIF', iStudy, iSubject, ImportOptions);
    else
        import_data(selectedFile, [], 'FIF', iStudy, iSubject, ImportOptions);
    end
    
    [sStudy, iStudy]=bst_get('Study', currentStudyName);
    selectedStudies(f) = iStudy;
end

    
   