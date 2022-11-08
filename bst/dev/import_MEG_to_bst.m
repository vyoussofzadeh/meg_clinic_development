function studyFileName = import_MEG_to_bst(selectedFile, iSubject, studyName, OPTIONS)

% recordingType:    spontaneous or functional
%
% selectedFile:     name of the MEG data file to import
%
%           OPTIONS.ImportRaw
%           OPTIONS.EventRecMaps
%           OPTIONS.SpectralMaps
%% ---------------- IMPORT RECORDINGS -------------------------------------
% Get default structure for configuring import
ImportOptions = db_template('ImportOptions');
% ImportOptions = struct(...
%     'UseEvents',        0, ...                 % {0,1}: If 1, perform epoching around the selected events
%     'EventsTimeRange',  [-0.1000 0.3000], ...  % Time range for epoching, zero is the event onset (if epoching is enabled)
%     'GetAllEpochs',     0, ...                 % {0,1}: Import all arrays, no matter how many they are
%     'iEpochs',          1, ...                 % Array of indices of epochs to import (if GetAllEpochs is not enabled)
%     'SplitRaw',         0, ...                 % {0,1}: If 1, and if importing continuous recordings (no epoching, no events): split recordings in small time blocks
%     'SplitLength',      2, ...                 % Duration of each split time block, in seconds
%     'Resample',         0, ...                 % Enable resampling (requires Signal Processing Toolbox)
%     'ResampleFreq',     0, ...                 % Resampling frequency (if resampling is enabled)
%     'UseCtfComp',       1, ...                 % Get and apply CTF 3rd gradient correction if available 
%     'UseSsp',           1, ...                 % Get and apply SSP (Signal Space Projection) vectors if available
%     'RemoveBaseline',   'no', ...              % Method used to remove baseline of each channel: {no, all, time, sample}
%     'BaselineRange',    [], ...                % [tStart,tStop] If RemoveBaseline is 'time';  [sampleStart,sampleStop] If RemoveBaseline is 'sample'; Else ignored
%     'ImportMode',       'Epoch', ...           % Import mode:  {Epoch, Time, Event}
%     'events',           [], ...                % Events structure: (label, epochs, samples, times, reactTimes, select)
%     'CreateConditions', 0);                    % {0,1} If 1, create new conditions in Brainstorm database if it is more convenient

% Set the way we want to import the recordings
studyFileName = [];
if OPTIONS.ImportRaw
    
    % -----Import -annot.fif events
    if (OPTIONS.EventRecMaps || OPTIONS.EventAve) && OPTIONS.UseAnnotFile   
        [sStudy, iStudy]=bst_get('Study', studyName);
        
        ImportOptions.ImportMode = 'Event';
        ImportOptions.UseEvents = 1;
        ImportOptions.EventsTimeRange = [-.300, .100];
        ImportOptions.UseSsp = 1; 
        ImportOptions.RemoveBaseline = 'time';
        ImportOptions.BaselineRange  = [-0.300 -0.200];
        ImportOptions.CreateConditions = 0;
        ImportOptions.AutoAnswer=0;
        ImportOptions.AlignSensors = 2;
                
        % Look for -annot file, if it exists, find events that have not
        % been imported.
        [path, name, ext] = fileparts(selectedFile);
        annotFile = fullfile(path, [name '-annot.fif']);
        iEvt = [];
        if exist(annotFile,'file')        
            % Open FIF file, to get the events
            sFile = in_fopen_fif(selectedFile, [], 1, annotFile);

            % Select events that have not yet been imported
            for i=1:length(sFile.events)
                dataIndices = [];
                label = '';
                if ~isempty(sStudy)
                    DataFiles = sStudy.Data;
                    % Filter results
                    label = {sFile.events(i).label};
                    pat=strrep(label, ' #','__');
                    x=regexp({DataFiles.FileName}, pat);
                    c=cellfun(@isempty, x);
                    dataIndices = find(c==0);
                end

                if isempty(dataIndices) && ~strcmp('Event #0', label)
                    iEvt = [iEvt i];
                end
            end           
            if ~isempty(iEvt)
                ImportOptions.events = sFile.events(iEvt);
                ImportOptions.AutoAnswer = 1;
            else
                return
            end
        else
            % Open FIF file, no -annot file exists, so prompt the user to
            % input an events file
            sFile = in_fopen_fif(selectedFile);

            % Find if these events were already imported
            iEvt = [];
            for i=1:length(sFile.events)
                dataIndices = [];
                label = '';
                if ~isempty(sStudy)
                    DataFiles = sStudy.Data;
                    % Filter results
                    label = {sFile.events(i).label};
                    pat=strrep(label, ' #','__');
                    x=regexp({DataFiles.FileName}, pat);
                    c=cellfun(@isempty, x);
                    dataIndices = find(c==0);
                end

                if isempty(dataIndices) && ~strcmp('Event #0', label)
                    iEvt = [iEvt i];
                end
            end           
            if ~isempty(iEvt)
                ImportOptions.events = sFile.events(iEvt);
                ImportOptions.AutoAnswer = 1;
            else
                return
            end          
        end
        
        % Import recordings   
        import_data(sFile, 'FIF', iStudy, iSubject, ImportOptions);       
    end

    % -----Import events from .eve file
    if (OPTIONS.EventRecMaps || OPTIONS.EventAve) && ~OPTIONS.UseAnnotFile   
        [sStudy, iStudy]=bst_get('Study', studyName);
        
        ImportOptions.ImportMode = 'Event';
        ImportOptions.UseEvents = 1;
        ImportOptions.EventsTimeRange = [-.300, .100];
        ImportOptions.UseSsp = 1; 
        ImportOptions.RemoveBaseline = 'time';
        ImportOptions.BaselineRange  = [-0.300 -0.200];
        ImportOptions.CreateConditions = 0;
        ImportOptions.AutoAnswer=0;
        ImportOptions.AlignSensors = 2;

        % Open FIF file, no -annot file exists, so prompt the user to
        % input an events files
        sFile = in_fopen_fif(selectedFile);

        iEvt = [];
        for i=1:length(sFile.events)
            dataIndices = [];
            label = '';
            if ~isempty(sStudy)
                DataFiles = sStudy.Data;
                % Filter results
                label = {sFile.events(i).label};
                pat=strrep(label, ' #','__');
                x=regexp({DataFiles.FileName}, pat);
                c=cellfun(@isempty, x);
                dataIndices = find(c==0);
            end

            if isempty(dataIndices) && ~strcmp('Event #0', label)
                iEvt = [iEvt i];
            end
        end
        % If some events still need to be imported
        if ~isempty(iEvt)
            ImportOptions.events = sFile.events(iEvt);
            ImportOptions.AutoAnswer = 0;
        else
            return
        end 
        % Import recordings   
        import_data(sFile, 'FIF', iStudy, iSubject, ImportOptions);   
       
    end

    % -----Import Raw Chunks
    if OPTIONS.SpectralMaps || OPTIONS.BkgrndSources
        ImportOptions = db_template('ImportOptions');
        
        % Open FIF file
        AutoAnswer = 1;
        sFile = in_fopen_fif(selectedFile, [], AutoAnswer, 'ignore');

        ImportOptions.ImportMode = 'Time';
        ImportOptions.UseEvents = 0;
        ImportOptions.TimeRange = sFile.prop.times;
        ImportOptions.GetAllEpochs = 0;
        ImportOptions.SplitRaw = 1;
        ImportOptions.SplitLength = 2;
        ImportOptions.UseSsp = 1;
        ImportOptions.RemoveBaseline = 'all';
        ImportOptions.AutoAnswer = 1;
        ImportOptions.AlignSensors = 2;

        % Beth short cut for neurofeedback study, only import first segment
        % ImportOptions.TimeRange(2) = ImportOptions.TimeRange(1)+2;
        
        % Import recordings
        [sStudy, iStudy]=bst_get('Study', studyName);
        import_data(sFile, 'FIF', iStudy, iSubject, ImportOptions);
    end
        
else
    % ------- Import evoked file
    [sStudy, iStudy]=bst_get('Study', studyName);
    iEvt = [];
    % Open FIF file, to get the events
    sFile = in_fopen_fif(selectedFile, [], 1, 'STI101');
    
    if ~isempty(sStudy)
        % Select events that have not yet been imported
        for i=1:length(sFile.epochs)
            DataFiles = sStudy.Data;
            % Filter results
            label = {sFile.epochs(i).label};
            x=regexp({DataFiles.FileName}, label);
            c=cellfun(@isempty, x);
            dataIndices = find(c==0);

            if isempty(dataIndices)
                iEvt = [iEvt i];
            end
        end           
        if ~isempty(iEvt)
            ImportOptions.events = sFile.events(iEvt);
            ImportOptions.AutoAnswer = 1;
        else
            return
        end
    end

    ImportOptions.ImportMode     = 'Epoch';
    ImportOptions.GetAllEpochs   = 1;
    ImportOptions.UseSsp = 1;
    ImportOptions.RemoveBaseline = 'time';
    ImportOptions.BaselineRange  = [-0.200 -0.005];
    ImportOptions.CreateConditions = 0;
    ImportOptions.AutoAnswer=1;
    ImportOptions.AlignSensors = 2;

    % Import recordings
    
    import_data(sFile, 'FIF', iStudy, iSubject, ImportOptions);
    
end

