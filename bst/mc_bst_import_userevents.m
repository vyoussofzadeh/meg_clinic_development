function selectedStudies = mc_bst_import_userevents(rawFiles, eventList)
% mc_bst_import_userevents: imports the user defined event epochs
% from the orig MEG raw data
%
% USAGE:    selectedStudies = mc_bst_import_userevents(rawFiles, eventList)
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

selectedStudies = zeros(1,length(rawFiles));
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
    if ~isempty(iStudy)
        selectedStudies(f) = iStudy;
    end
    % Get default structure for configuring import
    ImportOptions = db_template('ImportOptions');
    
    % -----Import -annot.fif events
    ImportOptions.ImportMode = 'Event';
    ImportOptions.UseEvents = 1;
    ImportOptions.EventsTimeRange = [-.300, .100];
    ImportOptions.UseSsp = 1; 
    ImportOptions.RemoveBaseline = 'time';
    ImportOptions.BaselineRange  = [-0.300 -0.200];
    ImportOptions.CreateConditions = 0;
    ImportOptions.DisplayMessages = 0;
    ImportOptions.ChannelAlign = 2;

    % Look for -annot file, if it exists, find events that have not
    % been imported.
    [path, name, ext] = fileparts(selectedFile);
    annotFile = fullfile(path, [name '-annot.fif']);
    iEvt = [];
    if exist(annotFile,'file')
        ImportOptions.EventsMode = annotFile;
        % Open FIF file, to get the events
        sFile = in_fopen_fif(selectedFile,ImportOptions);

        % find events from the eventList in the annot file
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
                    x=regexp({DataFiles.FileName}, eventList(i));
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
        % Open FIF file, no -annot file exists, so prompt the user to
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
                    x=regexp({DataFiles.FileName}, eventList(i));
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
            continue
        end
    end

    % Import recordings
    %NewFiles = import_data(DataFiles, ChannelMat, FileFormat, iStudyInit, iSubjectInit, ImportOptions)
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

    
   