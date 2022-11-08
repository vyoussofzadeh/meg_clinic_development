function mc_bst_run_pipeline(varargin)
% mc_bst_run_pipeline: run brainstorm scripts
%
% USAGE:    set(importMEGButton, 'ActionPerformedCallback', {@mc_bst_run_pipeline, 'ImportMRI', mc})
%           mc_bst_run_pipeline('ImportMRI', mc)
%           set(importMEGButton, 'ActionPerformedCallback', {@mc_bst_run_pipeline, 'ImportDIP', mc});
%           mc_bst_run_pipeline('ImportDIP', mc)
%           set(importMEGButton, 'ActionPerformedCallback', {@mc_bst_run_pipeline, 'Background', mc});
%           mc_bst_run_pipeline('Background', mc)
%           set(importMEGButton, 'ActionPerformedCallback', {@mc_bst_run_pipeline, 'Interictal', mc});
%           mc_bst_run_pipeline('Interictal', mc)
%           set(importMEGButton, 'ActionPerformedCallback', {@mc_bst_run_pipeline, 'Functional', mc});
%           mc_bst_run_pipeline('Functional', mc)
%           
%
% INPUT:    mc = megclinic instance
%
% Author: Elizabeth Bock, 2009-2011
% --------------------------- Script History ------------------------------
% EB 27-AUG-2009  Creation
% EB 24-MAY-2010  Updates for importing and processing in batches
% EB 26-MAY-2010  Updates for callback
% EB 12-JULY-2011 Updates for pipeline processing
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
    mc_bst_create_protocol();
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
[sSubject, iSubject] = bst_get('Subject' ,subjectName);

if isempty(iSubject) % Subject does not exist
    [sSubject, iSubject] = mc_bst_create_subject(subjectName);
end

switch (processName)
    case 'ImportMRI'
        %% Import MRI
        if isempty(sSubject.Anatomy) || isempty(sSubject.Surface)
            % Import the MRI
            mc_bst_import_mriandsurfaces(subjectName, mriDir);
        end
        % Update the workflow
        [sSubject, iSubject] = bst_get('Subject' ,subjectName);
        if ~isempty(sSubject.Anatomy)
            bst_mri_file = fullfile(sProtocolInfo(iProtocol).SUBJECTS, sSubject.Anatomy.FileName);
            mc.setWorkflowVariable(GUI.WorkflowConfig.BSTMRI, bst_mri_file, true);
        end

    case 'ImportDIP'
        %% Import DIP file
        dipName = mc_bst_importdipoles(selectedPaths);
        mc.setWorkflowVariable(GUI.WorkflowConfig.DIPOLEIMG, dipName, true);
        
    case 'Background'
        %% Background
        configOptions = BrainstormIO.BstConfig.getConfigOptions();
        sFiles = [];
        
        % Import
        selectedPaths = cellstr(char(GUI.DataSet.currentSession.getType(GUI.Session.SPONT)));
        if length(selectedPaths) == 1 && isempty(selectedPaths{1})
            return;
        end
        selectedStudies = mc_bst_import_rawchunks(selectedPaths);

        % Pipeline
        ind = double(BrainstormIO.BstConfig.PIPELINE_RAW) + 1; % Java uses zero indexing
        if configOptions(ind)
            sFiles = mc_bst_background_pipeline(selectedStudies);
        end
        
        % Images
        StoreImgDir = fullfile(char(GUI.DataSet.analysesDataPath), 'background');
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
        if length(selectedPaths) == 1 && isempty(selectedPaths{1})
            return;
        end
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
        StoreImgDir = fullfile(char(GUI.DataSet.analysesDataPath),'spikes');
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
        %% functional paradigm events analysis
        configOptions = BrainstormIO.BstConfig.getConfigOptions();
        
        % Import
        selectedPaths = cellstr(char(GUI.DataSet.currentSession.getType(GUI.Session.FUNCTIONALFILES)));
        selectedEvents = cellstr(char(GUI.DataSet.currentSession.getType(GUI.Session.FUNCTIONALEVENTS)));
        selectedStudies = mc_bst_import_fxnlevents(selectedPaths, selectedEvents);

        % Pipeline
        ind = double(BrainstormIO.BstConfig.PIPELINE_FUNCTIONAL) + 1; % Java uses zero indexing
        if configOptions(ind)
            disp('TODO: Create pipelines for each functional paradigm.')
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
        disp('TODO: Generate script to create images of functional events.')
end
end