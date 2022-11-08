function studyFileName = process_import_MEG_to_bst(recordingType, selectedFile, iSubject)

% recordingType:    spontaneous or functional
%
% selectedFile:     name of the MEG data file to import
%

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

switch lower(recordingType)
    case 'spontaneous'
        % Check for .eve files
        [path, name, ext, vrn] = fileparts(selectedFile);
        eveFiles = dir(fullfile(path, '*.eve'));
        nEveFiles = length(eveFiles);
        if nEveFiles % atleast one .eve file exists
            ImportOptions.ImportMode = 'Event';
            ImportOptions.UseEvents = 1;
            ImportOptions.EventsTimeRange = [-.300, .100];
            ImportOptions.UseSsp = 1; 
            ImportOptions.RemoveBaseline = 'time';
            ImportOptions.BaselineRange  = [-0.300 -0.200];
            ImportOptions.CreateConditions = 0;
            %ImportOptions.AutoAnswer=1;

            % Import recordings (using the same options)
            NewFiles = import_data(selectedFile, 'FIF', [], iSubject, ImportOptions);
            [sStudy, iStudy] = bst_get('Study');

            if ImportOptions.CreateConditions
                numStudies = length(NewFiles);
                for i=1:numStudies   
                    studyFileName{i} = sStudy.FileName;
                    [sStudy, iStudy] = bst_get('Study', iStudy-i);
                end
            else
                studyFileName{1} = sStudy.FileName;
            end
        else % just import the raw data
            ImportOptions.ImportMode = 'Time';
            ImportOptions.UseEvents = 0;
            ImportOptions.GetAllEpochs = 0;
            ImportOptions.SplitRaw = 1;
            ImportOptions.SplitLength = 2;
            ImportOptions.UseSsp = 1;
            ImportOptions.RemoveBaseline = 'time';
            ImportOptions.AutoAnswer = 0;
            
            % Import recordings (using the same options)
            NewFiles = import_data(selectedFile, 'FIF', [], iSubject, ImportOptions);
            [sStudy, iStudy] = bst_get('Study');
            studyFileName{1} = sStudy.FileName;
        end
        
    case 'functional'
        ImportOptions.ImportMode     = 'Epoch';
        ImportOptions.GetAllEpochs   = 1;
        ImportOptions.UseSsp = 1;
        ImportOptions.RemoveBaseline = 'time';
        ImportOptions.BaselineRange  = [-0.200 -0.005];
        ImportOptions.CreateConditions = 0;
        ImportOptions.AutoAnswer=1;

        % Import recordings (using the same options)
        NewFiles = import_data(selectedFile, 'FIF', [], iSubject, ImportOptions);
        [sStudy, iStudy] = bst_get('Study');

        if ImportOptions.CreateConditions
            numStudies = length(NewFiles);
            for i=1:numStudies   
                studyFileName{i} = sStudy.FileName;
                [sStudy, iStudy] = bst_get('Study', iStudy-i);
            end
        else
            studyFileName{1} = sStudy.FileName;
        end

end

