function brainstorm_runProcess(varargin)
% brainstorm_runProcess: run brainstorm scripts
%
% USAGE:    set(importMEGButton, 'ActionPerformedCallback', {@brainstorm_runProcess, 'ImportMEG', mc})
%           brainstorm_runProcess('ImportMRI', mc)
%           set(importMEGButton, 'ActionPerformedCallback', {@brainstorm_runProcess, 'ImportMRI', mc});
%           brainstorm_runProcess('ImportMEG', mc)
%           set(importMEGButton, 'ActionPerformedCallback', {@brainstorm_runProcess, 'Batch', mc});
%           brainstorm_runProcess('Batch', mc)
%           brainstorm_runProcess('ViewDipoles', mc, data)
%
% INPUT:    mc = megclinic instance
%           data = input data for process - 'ViewDipoles' needs volume matrix
%
% Author: Elizabeth Bock, 2009
% --------------------------- Script History ------------------------------
% EB 27-AUG-2009  Creation
% EB 24-MAY-2010  Updates for importing and processing in batches
% EG 26-MAY-2010  Updates for callback
% -------------------------------------------------------------------------
global GlobalData
% Parse inputs
if nargin > 3
    % This is the callback (obj = varargin{1}, event = varargin{2})
    processName = varargin{3};
    mc = varargin{4};
else
    % This is the direct usage
    processName = varargin{1};
    mc = varargin{2};
    if nargin == 3
        data = varargin{3};
    end
end

if nargin == 5
    data = varargin{5};
end

% Get the message area
messages = GUI.CallbackInterface.messageTextArea;

% Get all the selected paths from the database tree
selectedPaths = mc.getSelectionPaths();

% Get the subject name and MRI Directory
subjectName = char(mc.getInfo(GUI.Config.I_SUBJECT));
try
    mriDir = char(mc.getInfo(GUI.Config.I_MRIDIR));
catch ME
    %Open a dialog to set the MRIDIR
    mriDir = uigetdir([], 'Select the MRI Directory');
end

%% ----------- Start BrainStorm -------------------------------------------
% Start brainstorm without the GUI
bstRunning = brainstorm('status');
if ~bstRunning
    brainstorm start
end

%% ----------- Set Current Protocol and Subject ---------------------------
currentProtocol = char(BrainstormIO.BstConfig.BST_PROTOCOL_NAME);
if isempty(currentProtocol)
    currentProtocol = inputdlg('Enter the Brainstorm protocol name','Brainstorm Protocol Name');
end

%sProtocolInfo = bst_get('ProtocolsListInfo');
sProtocolInfo = GlobalData.DataBase.ProtocolInfo;
nProtocols = length(sProtocolInfo);
iProtocol = 0;
for n=1:nProtocols
    if strcmp(sProtocolInfo(n).Comment, currentProtocol)
        iProtocol = n;
        gui_brainstorm('SetCurrentProtocol', iProtocol);
        break;
    end
end

if ~iProtocol % protocol does not exist
    % Create Protocol
    process_create_bst_protocol();
    iProtocol = nProtocols+1;
    sProtocolInfo = GlobalData.DataBase.ProtocolInfo;
end

subject = sProtocolInfo(iProtocol).SUBJECTS;
index = findstr(subject, 'brainstorm_db');
bst_db_dir = subject(1:index+12);
% Check brainstorm directory
if ~strcmp(GlobalData.DataBase.BrainstormDbDir, bst_db_dir);
    GlobalData.DataBase.BrainstormDbDir = bst_db_dir;
end

% Check to see if subject exists
[sSubject, iSubject] = bst_get('SubjectWithName' ,subjectName);

if isempty(iSubject) % Subject does not exist
    [sSubject, iSubject] = process_create_bst_subject(subjectName);
end

switch (processName)
    case 'ImportMRI'
        %% Import MRI
        if isempty(sSubject.Anatomy) || isempty(sSubject.Surface)
            % Import the MRI
            process_import_MRI_to_bst(subjectName, mriDir);
        end
        % Update the workflow
        [sSubject, iSubject] = bst_get('SubjectWithName' ,subjectName);
        if ~isempty(sSubject.Anatomy)
            bst_mri_file = fullfile(sProtocolInfo(iProtocol).SUBJECTS, sSubject.Anatomy.FileName);
            mc.setWorkflowVariable(GUI.WorkflowConfig.BSTMRI, bst_mri_file, true);
        end

    case 'ImportMEG'
        %% Import MEG recording
        if findstr(selectedPaths, '.bdip')
            %import dipole file
            brainstorm_importDipoles(selectedPaths);
        else
            %import raw, event or evoked files
            if selectedPaths.size > 1
                GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_WARNING, 'Too many files selected.  Only the first selected file will be used. If you want to import several files, select the Batch Analysis Option');
            end
            selectedFile = char(selectedPaths.get(0));
            sFile = in_fopen_fif(selectedFile);

            % Import recordings
            [path, fileName] = fileparts(selectedFile);
            studyDir = sProtocolInfo(iProtocol).STUDIES;
            subjectName = sSubject.Name;
            currentStudyName = fullfile(studyDir, subjectName, fileName, 'brainstormstudy.mat');
            [sStudy, iStudy] = bst_get('Study', currentStudyName);

            import_data(sFile, 'FIF', iStudy, iSubject);
        end


    case 'Batch'
        %% Batch Analysis
        %import files
        disp(sprintf('%s\n','Importing data...'));
        brainstorm_importMeg(selectedPaths, mc)

        % Head model, noise cov and source estimation
        for j=1:selectedPaths.size
            % -----Get current study name
            selectedFile = char(selectedPaths.get(j-1));
            [path, fileName, ext, vrsn] = fileparts(selectedFile);
            studyDir = sProtocolInfo(iProtocol).STUDIES;
            subjectName = sSubject.Name;
            currentStudyName = fullfile(studyDir, subjectName, fileName, 'brainstormstudy.mat');
            [sStudy, iStudy] = bst_get('Study', currentStudyName);
            panel_protocols('SelectStudyNode', iStudy);

            % Keep track of selected studies
            selectedStudies(j) = iStudy;

            % -----Check for head model
            disp(sprintf('%s\n','Computing head model...'));
            if isempty(sStudy.HeadModel)
                messages.setText(['Brainstorm - Compute Head Model: ' fileName])
                process_create_head_model(currentStudyName);
                %Refresh sStudy
                [sStudy, iStudy] = bst_get('Study', currentStudyName);
                if isempty(sStudy.HeadModel)
                    error('Cannot create head model');
                end
            end

            % -----Check for Noise Covariance Matrix
            disp(sprintf('%s\n','Computing noise covariance matrix...'));
            if isempty(sStudy.NoiseCov)
                messages.setText(['Brainstorm - Get Noise Cov: ' fileName])
                currentWorkflow = mc.getCurrentWorkflow();
                NoiseCovMat = get_noiseCov_matrix(studyDir, subjectName, currentWorkflow);
                if isempty(NoiseCovMat)
                    error('Cannot get the noise covariance matrix');
                end

                [sStudy, iStudy] = bst_get('Study', currentStudyName);
                megCh = sStudy.Channel.nbChannels;
                covCh = length(NoiseCovMat.NoiseCov);
                % If necessary, adjust matrix size
                if megCh < covCh
                    % Use only the first megCh x megCh elements
                    temp = NoiseCovMat.NoiseCov(1:megCh, 1:megCh);
                    NoiseCovMat.NoiseCov = temp;
                elseif megCh > covCh
                    % Pad the matrix with zeros
                    temp = NoiseCovMat.NoiseCov;
                    temp(megCh,megCh) = 0;
                    NoiseCovMat.NoiseCov = temp;
                end

                % Import noise cov into current study
                AutoReplace = 1;
                import_noisecov(iStudy, NoiseCovMat, AutoReplace);
            end

            % -----Source Estimation
            disp(sprintf('%s\n','Estimating sources...'));
            dataIndices = [];
            if ~isempty(sStudy)
                ResultFiles = sStudy.Result;
                % Filter results
                pat='MN: shared kernel';
                x=regexp({ResultFiles.Comment}, pat);
                c=cellfun(@isempty, x);
                dataIndices = find(c==0);
                if isempty(dataIndices)
                    pat='MNE:';
                    x=regexp({ResultFiles.Comment}, pat);
                    c=cellfun(@isempty, x);
                    dataIndices = find(c==0);
                end
            end

            if isempty(sStudy) || isempty(dataIndices)
                messages.setText(['Brainstorm - Source Estimation: ' fileName])
                [sStudy, iStudy] = bst_get('Study', currentStudyName);
                script_minnorm(iStudy, [], 'MN: shared kernel');
            end

            mc.setMessage(GUI.Config.M_EMPTY);
            % -----Update database
            db_reload_studies( iStudy );
        end

        % -----Processes
        for k=1:selectedPaths.size
            % -----Get current study name
            selectedFile = char(selectedPaths.get(k-1));
            [path, fileName, ext, vrsn] = fileparts(selectedFile);
            studyDir = sProtocolInfo(iProtocol).STUDIES;
            subjectName = sSubject.Name;
            currentStudyName = fullfile(studyDir, subjectName, fileName, 'brainstormstudy.mat');
            [sStudy, iStudy] = bst_get('Study', currentStudyName);
            panel_protocols('SelectStudyNode', iStudy);
            db_load_studies();

            % -----Spectal Analysis
            if BrainstormIO.BstConfig.SPECTRAL_MAPS
                ResultFiles = sStudy.Result;
                % Filter results
                pat='results_decomp';
                x=regexp({ResultFiles.FileName}, pat);
                c=cellfun(@isempty, x);
                dataIndices = find(c==0);
                if isempty(dataIndices)
                    % Generate Results
                    messages.setText(['Brainstorm - Spectral Maps: ' fileName])
                    process_spectral_analysis(currentStudyName);
                end
            end

            % -----Event Latency and Recurrence Maps
            if BrainstormIO.BstConfig.EVENT_LATENCY
                ResultFiles = sStudy.Result;
                % Filter results
                pat='results_recurr';
                x=regexp({ResultFiles.FileName}, pat);
                c=cellfun(@isempty, x);
                dataIndices = find(c==0);
                if isempty(dataIndices) || BrainstormIO.BstConfig.TIMEWIN
                    % Generate Results
                    messages.setText(['Brainstorm - Recurrence Maps: ' fileName])
                    process_event_latency(currentStudyName);
                end
            end
            mc.setMessage(GUI.Config.M_DONE);
        end

        % -----Intra subject processes
        % Analyze Events (1001, 1002, 1003, and 1004)
        if BrainstormIO.BstConfig.EVENT_LATENCY
            eventsToTest = {'1001';'1002';'1003';'1004';'2000';'2001'};
            for e = 1:4
                categoryKeyword = ['Event #' eventsToTest{e}];
                [DataFiles, ResultFiles] = get_category_files(selectedStudies, categoryKeyword);
                if ~isempty(DataFiles)
                    nFiles = num2str(length(DataFiles));
                    newComment = ['Avg: Event #' eventsToTest{e} ' ' nFiles ' files'];
                    % -----Average time series
                    average_event_data(DataFiles, 1, newComment);
                    % -----Average sources
                    sFile = average_event_sources(ResultFiles, 1, newComment);
                    % -----z-score on average sources
                    zscore_event_sources({sFile.FileName}, [newComment '| band(5-40Hz) zscore']);
                end
            end
        end

    case 'Images'
        %% Generate Images
        nFiles = selectedPaths.size;
        for s = 1:nFiles
            [p, name] = fileparts(char(selectedPaths.get(s-1)));
            selectedFiles(s) = {name};
        end
        if BrainstormIO.BatchImageConfig.INCLUDE_INTRA
            nFiles = nFiles + 1;
            selectedFiles(nFiles) = {'@intra'};
        end

        for k=1:nFiles
            fileName = selectedFiles{k};
            % -----Get current study name
            studyDir = sProtocolInfo(iProtocol).STUDIES;
            subjectName = sSubject.Name;
            currentStudyName = fullfile(studyDir, subjectName, fileName, 'brainstormstudy.mat');
            [sStudy, iStudy] = bst_get('Study', currentStudyName);
            panel_protocols('SelectStudyNode', iStudy);
            db_load_studies();

            % -----Get Analyses and Results Directory
            StoreImgDir = char(GUI.DataSet.analysesDataPath);
            p = fileparts(currentStudyName);

            % -----Spectral Analysis
            if BrainstormIO.BatchImageConfig.SPEC_DECOMP_IMAGES
                sFiles = [];
                messages.setText(['Generate Images - Spectral Maps: ' fileName])
                % Filter results
                sFiles = dir([p '/results_decomp*']);
                if isempty(sFiles)
                    disp('No Spectral Maps available for snapshots');
                else
                    % Create Images
                    batch_MRIandResults(strcat([p '/'], {sFiles.name}), [StoreImgDir '/background'], 0);
                end
            end

            % -----Averages
            if BrainstormIO.BatchImageConfig.AVERAGE_IMAGES
                sFiles = [];
                messages.setText(['Generate Images - Averages: ' fileName])
                % Filter results
                sFiles = dir([p '/results_average*_bandpass.mat']);
                if isempty(sFiles)
                    disp('No Averages available for snapshots');
                else
                    % Create Images
                    batch_ContactSheetandResults(strcat([p '/'], {sFiles.name}), StoreImgDir, 'average');
                end
            end

            % -----Z-score
            if BrainstormIO.BatchImageConfig.ZSCORE_IMAGES
                sFiles = [];
                messages.setText(['Generate Images - zScore: ' fileName])
                % Filter results
                sFiles = dir([p '/*_zscore.mat']);
                if isempty(sFiles)
                    disp('No zscore results available for snapshots');
                else
                    % Create Images
                    batch_ContactSheetandResults([], strcat([p '/'], {sFiles.name}), StoreImgDir, 'zscore');
                end
            end

            % -----Event Latency and Recurrence Maps
            if BrainstormIO.BatchImageConfig.RECURR_MAP_IMAGES
                sFiles = [];
                messages.setText(['Generate Images - Event Latency and Recurrence Maps: ' fileName])
                % Filter results
                sFiles = dir([p '/results_recurr*']);
                if isempty(sFiles)
                    disp('No recurrence or latency maps available for snapshots');
                else
                    % Create Images
                    batch_MRIandResults(strcat([p '/'], {sFiles.name}), StoreImgDir, 1);
                end
            end
        end
    case 'Background'
        %% Background
        configOptions = BrainstormIO.BstConfig.getConfigOptions();
        sFiles = [];
        
        % Import
        selectedPaths = cellstr(char(GUI.DataSet.currentSession.getType(GUI.Session.SPONT)));
        selectedStudies = mc_bst_import_rawchunks(selectedPaths);

        % Pipeline
        ind = double(BrainstormIO.BstConfig.PIPELINE_RAW) + 1; % Java uses zero indexing
        if configOptions(ind)
            sFiles = mc_bst_background_pipeline(selectedStudies);
        end
        
        % Images
        StoreImgDir = fullfie(char(GUI.DataSet.analysesDataPath), 'background');
        ind = double(BrainstormIO.BstConfig.IMAGES_RAW) + 1; % Java uses zero indexing
        if configOptions(ind)
            if isempty(sFiles)
                % Go through the studies and find the results
                for ss = 1:length(selectedStudies)
                    sStudy = bst_get('Study',selectedStudies(ss));
                    ind = find(~cellfun(@isempty, (strfind({sStudy.Result.FileName}, 'results_decomp'))));
                    if ~isempty(ind)
                        % Create Images
                        batch_MRIandResults({sStudy.Result(ind).FileName}, StoreImgDir, 0);
                    end
                end
            else
                % Create Images
                batch_MRIandResults({sFiles.FileName}, StoreImgDir, 0);
            end
        end
        
    case 'Interictal'
        %% Interictal spike analysis
        configOptions = BrainstormIO.BstConfig.getConfigOptions();
        
        % Import
        selectedPaths = cellstr(char(GUI.DataSet.currentSession.getType(GUI.Session.INTERICTALFILES)));
        selectedEvents = cellstr(char(GUI.DataSet.currentSession.getType(GUI.Session.INTERICTALSPIKES)));
        selectedStudies = mc_bst_import_userevents(selectedPaths, selectedEvents);

        % Pipeline
        ind = double(BrainstormIO.BstConfig.PIPELINE_SPIKES) + 1; % Java uses zero indexing
        if configOptions(ind)
            mc_bst_interictal_pipeline(selectedStudies);
        end
        
        % Images
        % include the @intra study
        selectedStudies = [selectedStudies 2];
        
        % confirm storage directory
        StoreImgDir = fullfile(char(GUI.DataSet.analysesDataPath), 'spikes');
        if exist(StoreImgDir,'dir') ~= 7
            mkdir(StoreImgDir);
        end
        % Go through the studies and find the results
        ind = double(BrainstormIO.BstConfig.IMAGE_SPIKES) + 1; % Java uses zero indexing
        if configOptions(ind)
            % -----Filtered Averages
            for ss = 1:length(selectedStudies)
                sStudy = bst_get('Study',selectedStudies(ss));
                ind = find(~cellfun(@isempty, (regexp({sStudy.Result.FileName},'.*/results_average.*_bandpass.mat'))));
                if ~isempty(ind)
                    % Create Images
                    batch_ContactSheetandResults({sStudy.Result(ind).FileName}, StoreImgDir, 'average');
                end
            end
            % -----Z-score
            for ss = 1:length(selectedStudies)
                sStudy = bst_get('Study',selectedStudies(ss));
                ind = find(~cellfun(@isempty, (regexp({sStudy.Result.FileName},'.*/results_average.*_zscore.mat'))));
                if ~isempty(ind)
                    % Create Images
                    batch_ContactSheetandResults({sStudy.Result(ind).FileName}, StoreImgDir, 'zscore');
                end
            end
            % -----Event Latency and Recurrence Maps
            for ss = 1:length(selectedStudies)
                sStudy = bst_get('Study',selectedStudies(ss));
                ind = find(~cellfun(@isempty, (regexp({sStudy.Result.FileName},'.*/results_recurr*.mat'))));
                if ~isempty(ind)
                    % Create Images
                    batch_MRIandResults({sStudy.Result(ind).FileName}, StoreImgDir, 1);
                end
            end
        end
        
    case 'Functional'
        %% Interictal spike analysis
        configOptions = BrainstormIO.BstConfig.getConfigOptions();
        
        % Import
        selectedPaths = cellstr(char(GUI.DataSet.currentSession.getType(GUI.Session.FUNCTIONALFILES)));
        selectedEvents = cellstr(char(GUI.DataSet.currentSession.getType(GUI.Session.FUNCTIONALEVENTS)));
        selectedStudies = mc_bst_import_fxnlevents(selectedPaths, selectedEvents);

        % Pipeline
        ind = double(BrainstormIO.BstConfig.PIPELINE_FUNCTIONAL) + 1; % Java uses zero indexing
        if configOptions(ind)
            mc_bst_functional_pipeline(selectedStudies);
        end
        
        % Images
        % include the @intra study
        selectedStudies = [selectedStudies 2];
        
        % confirm storage directory
        StoreImgDir = fullfile(char(GUI.DataSet.analysesDataPath), 'spikes');
        if exist(StoreImgDir, 'dir') ~= 7
            mkdir(StoreImgDir);
        end
        disp('TODO: Generate script to create images of functional events')
end
end

%% Average data
function sFile = average_event_data(DataFiles, includeFiltering, newComment)
% Process: Average Everything
sFile = {};
% Process: Average everything, abs
sFile = bst_process(...
    'CallProcess', 'process_average', ...
    DataFiles, [], ...
    'avgtype', 1, ...
    'isstd', 0, ...
    'Comment', newComment);

% Process: bandpass filter 5-40Hz
if includeFiltering
    FileNamesA = sFile.FileName;
    clear Processes sFile
    newComment = [newComment ' | band(5-40Hz)'];
    sFile = bst_process(...
        'CallProcess', 'process_bandpass', ...
        FileNamesA, [], ...
        'highpass', 5, ...
        'lowpass', 40, ...
        'sensortypes', 'EEG, MEG, MEG MAG, MEG GRAD', ...
        'overwrite', 0, ...
        'Comment', newComment);
end
end


%% Average sources
function sFile = average_event_sources(ResultFiles, includeFiltering, newComment)
% Process: Average Everything
sFile = {};
% Process: Average everything, abs
sFile = bst_process(...
    'CallProcess', 'process_average', ...
    ResultFiles, [], ...
    'avgtype', 1, ...
    'abs', 1, ...
    'isstd', 0, ...
    'Comment', newComment);

% Process: bandpass filter 5-40Hz
if includeFiltering
    FileNamesA = sFile.FileName;
    clear Processes sFile
    newComment = [newComment ' | band(5-40Hz)'];
    sFile = bst_process(...
        'CallProcess', 'process_bandpass', ...
        FileNamesA, [], ...
        'highpass', 5, ...
        'lowpass', 40, ...
        'sensortypes', 'EEG, MEG, MEG MAG, MEG GRAD', ...
        'overwrite', 0, ...
        'Comment', newComment);
end
end

%% zscore sources
function sFile = zscore_event_sources(ResultFiles, newComment)
sFile = {};
% Process: z score normalization [-300ms, 1000ms]
sFile = bst_process(...
    'CallProcess', 'process_zscore3', ...
    ResultFiles, [], ...
    'baseline', [-0.3, 1.0], ...
    'overwrite', 0, ...
    'Comment', newComment);
end


