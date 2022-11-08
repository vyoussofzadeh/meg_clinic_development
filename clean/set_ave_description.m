function FileNames = set_ave_description(FileNames, type)
% setAveDescription(FileNames, type)
% FileNames = structure of default file names
% type = functional, custom or raw
% ----- Get Workflow

% Default type is functional
if nargin < 2
    type = 'functional';
end
% Get current workflow
wf = GUI.DataSet.currentWorkflow;

%% Get ave description, stim source and mask
Events = [];
AcqPars = [];
switch (type)
    % Events exist in the raw recording
    case 'functional'
        % Find Event info name
        eveInfoFile = fullfile(FileNames.filelocation, [FileNames.protocol '_eventInfo.mat']);
        
        FileNames.aveName = char(wf.getName(GUI.WorkflowConfig.AVESSS));
        % If average description file does not exist, create one...
        if ~exist(fullfile(FileNames.filelocation, FileNames.aveDescriptionFile),'file')
            [Events, AcqPars, FileNames.aveDescriptionFile] = ave_write_description(FileNames);
            % Save events
            save(eveInfoFile,'Events','AcqPars')
        else
            % update the description file with the correct output names
            file = fullfile(FileNames.filelocation, FileNames.aveDescriptionFile);
            replace_text_line(file, 6, '\t%s', ['outfile ' FileNames.filelocation '/' FileNames.cleanAveFileName])
            replace_text_line(file, 7, '\t%s', ['logfile ' FileNames.filelocation '/' FileNames.logAveFileName])
        end
        
        % Get Events and AcqPars if not already loaded
        if isempty(Events) && isempty(AcqPars)
            if exist(eveInfoFile,'file')
                load(eveInfoFile)
            else
                % Extract events
                [Events, AcqPars] = parse_aveFile_events(fullfile(FileNames.filelocation, FileNames.aveName));
                % Save events
                save(eveInfoFile,'Events','AcqPars')
            end
        end           
  
        % If the event file does not exist create one now
        if ~exist(fullfile(FileNames.filelocation, FileNames.fxnlEvents), 'file')
            disp('Extracting events')
            extract_rawFile_events(Events, AcqPars, FileNames.filename, fullfile(FileNames.filelocation, FileNames.fxnlEvents));
        end

        % If the stim source is not defined in the workflow, do that now
        if strcmp(char(wf.getName(GUI.WorkflowConfig.STIMSOURCE)), '')
            stiCh = unique({Events(1:AcqPars.nCategories).eventChannel});
            % Find stim channels
            if length(stiCh) > 1
                disp(['***More than one stim channel was used, all events may not be averaged with MNE. Using' stiCh{1}])
            end
            stimSource = stiCh{1};
            wf.setType(GUI.WorkflowConfig.STIMSOURCE, stimSource)
        end

        % If the mask is not defined in the workflow, do that now
        if strcmp(char(wf.getName(GUI.WorkflowConfig.MASK)), '')
            masks = unique([Events(1:AcqPars.nCategories).eventNewMask]);
            % Find masks
            iMask = 1;
            if length(masks) > 1
                iMask = find(max(masks < 46152));                
                disp(['***More than one mask was used, all events may not be averaged with MNE. Using mask ' num2str(masks(iMask))])
            end
            mask = num2str(masks(iMask));
            wf.setType(GUI.WorkflowConfig.MASK, mask);
        end
        
        % Define event types in the workflow
        if strcmp(char(wf.getName(GUI.WorkflowConfig.EVENTLIST)), '')
            eventList = [Events(1:AcqPars.nCategories).eventNewBits];
            temp = strrep(num2str(eventList),'  ', ',');
            wf.setType(GUI.WorkflowConfig.EVENTLIST, temp);
        end

    % Events exist in an event file and an average description file have
    % been created by the user
    case 'custom'
        wf.setType(GUI.WorkflowConfig.MASK, '0');
        wf.setType(GUI.WorkflowConfig.STIMSOURCE, '0');
        FileNames.aveDescriptionFile = char(wf.getName(GUI.WorkflowConfig.CUSTOMAVEDESC));
        wf.setType(GUI.WorkflowConfig.AVEDESC, FileNames.aveDescriptionFile);
        if strcmp(FileNames.aveDescriptionFile,'')
            GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_WARNING, 'No custome average description file found.')
            return
        end

    % No events exist, set all variables to zero
    case 'raw'
        wf.setType(GUI.WorkflowConfig.MASK, '0');
        wf.setType(GUI.WorkflowConfig.STIMSOURCE, '0');
        FileNames.aveDescription = '';
        wf.setType(GUI.WorkflowConfig.AVEDESC, FileNames.aveDescriptionFile);
end
wf.save;
