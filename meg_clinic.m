function mc = meg_clinic( varargin )
% meg_clinic: Start MEG-Clinic
%
% USAGE:    meg_clinic()                            % Default, starts the GUI
%           meg_clinic('gui')                       % Start the GUI
%           meg_clinic('gui', rawDataPath)          % Start the GUI and load record  
%           meg_clinic('clean', rawDataPath)        % Batch cleaning 
%           meg_clinic('clean', rawDataPath, email) % Sends an email when complete
%           meg_clinic('setup')                     % Setup megclinic configurations
%
% INPUT:
%           rawDataPath = Path to a record (e.g. /MEG_data/project/subject/date)
%           email = email address for notification
%
% Author: Elizabeth Bock, 2009
% --------------------------- Script History ------------------------------
% EB 27-AUG-2009    Creation
% EB 21-MAY-2010    Updates to inputs and callbacks
% -------------------------------------------------------------------------

% ----- Setup MEG-Clinic environment
% Opengl software for use with Brainstorm
opengl software

% Get the megclinic homePath, assume we are in the megclinic folder
homePath = fileparts(which(mfilename));

% Java classes
% check that the dynamic classpath is empty

dynamic_jcp = javaclasspath('-dynamic');

if ~isempty(dynamic_jcp)
    
%     % VYZ, 07/13/22
%     for i=1:length(dynamic_jcp)
%         javarmpath(dynamic_jcp{i})
%     end
    errordlg(['The Java Classpath is not empty.' 10 10 ...
        'You should restart matlab to avoid errors using this software.'], 'MEG-Clinic Start');
    return
end
javaaddpath(fullfile(homePath, 'java', 'megclinic_development.jar'));

% Add BrainStorm JARs to classpath if setup is complete
if sum(strcmp(varargin,'setup')) == 0
    GUI.DataSet.initDataSet();
    bstPath = char(GUI.DataSet.bstAppPath);
    javaaddpath(strcat(bstPath,'/java/RiverLayout.jar'));
    javaaddpath(strcat(bstPath,'/java/brainstorm.jar'));
end

% Set the megclinic paths
set_paths('megclinic',homePath);

cd(homePath)


% Start a log file
logFile = GUI.MCLogFile;

% ----- Start MEG-Clinic GUI
if nargin == 0 % Default
    mc = GUI.MEGClinic('gui');
    assignCallbacks(mc);
    % Set app paths
    set_paths('apps')
    % Show the GUI
    logFile.write('Start GUI');
    mc.show();

elseif (nargin == 1) && (sum(strcmp(varargin, 'gui')) > 0)
    mc = GUI.MEGClinic('gui');
    assignCallbacks(mc);
    % Set app paths
    set_paths('apps')
    % Show the GUI
    logFile.write('Start GUI');
    mc.show();
    
elseif (nargin > 1) && (sum(strcmp(varargin, 'gui')) > 0)
    mc = GUI.MEGClinic(varargin);
    if ~mc.setupComplete
        return
    end
    assignCallbacks(mc);
    % Set app paths
    set_paths('apps')
    % Show the GUI
    logFile.write('Start GUI');
    mc.show();
    % ----- Test xfit settings
    if sum(strcmp(varargin,'testxfit')) > 0
        test_xfit_input(mc);
    end
    % ----- Test clean settings
    if sum(strcmp(varargin,'testclean')) > 0
        test_clean;
    end
    % ----- Test eog settings
    if sum(strcmp(varargin,'testeog')) > 0
        process_batch_eog(mc);
    end

% ----- Batch Cleaning
elseif (nargin > 1) && (sum(strcmp(varargin,'clean')) > 0)
    % Batch cleaning 
    mc = GUI.MEGClinic(varargin);
    if ~mc.setupComplete
        return
    end
    % Set app paths
    set_paths('apps')
    % No GUI
    logFile.write('No GUI');   
    if sum(strcmp(varargin, 'ongoing'))
        ongoingClean = ArtifactClean.CleanConfig;
        ongoingClean.INCLUDE_ONGOING = 1;
        ongoingClean.CLEANTAG = '_xtraClean';
    end
    process_batch_clean(mc);
   
% ----- Send an email to the user
    user = getenv('USER');
    if length(varargin) > 2
        command = ['mail -s ''megclinic'' ' varargin{3} [' < /home/' user '/megclinic_log.txt']];
    else
        command = ['mail -s ''megclinic'' ebock@mcw.edu' ['< /home/' user '/megclinic_log.txt']];
    end
    
    logFile.write(['command: ' command]);
    [s,w] = unix(command);
    logFile.write(w);
    exit_viewer(mc);
    

% ----- Setup Configurations
elseif sum(strcmp(varargin,'setup')) > 0
    Defaults.SetupConfiguration();

end

%     % VYZ, 04/04/23
dynamic_jcp = javaclasspath('-dynamic');
for i=1:length(dynamic_jcp)
    javarmpath(dynamic_jcp{i})
end
end

%% Assign Callbacks
function assignCallbacks(mc)
% assignCallbacks: Assign the button callbacks to the MEG-Clinic GUI
%
% INPUTS:   mc = instance of MEG-Clinic
% -------------------------------------------------------------------------

%Spike detection
hBstButton = handle(GUI.CallbackInterface.spikedetect, 'CallbackProperties');
set(hBstButton, 'ActionPerformedCallback',{@spikedetect, mc});

% Brainstorm
hBstButton = handle(GUI.CallbackInterface.startBrainstorm, 'CallbackProperties');
set(hBstButton, 'ActionPerformedCallback',{@brainstorm_callback, 'start'});

% Button Exit
hExitButton = handle(GUI.CallbackInterface.exitButton, 'CallbackProperties');
set(hExitButton, 'ActionPerformedCallback', {@exit_viewer, mc});

% Remove Artifacts
hCleanButton = handle(GUI.CallbackInterface.artifactCleanButton, 'CallbackProperties');
set(hCleanButton, 'ActionPerformedCallback', {@process_auto_clean, mc});

% Create xfit inputs for dipole fitting
hCfitButton = handle(GUI.CallbackInterface.writeCfitButton, 'CallbackProperties');
set(hCfitButton, 'ActionPerformedCallback', {@build_xfitCommand_files, mc});

% Generate evoked with clean data
hEvokedCleanButton = handle(GUI.CallbackInterface.genAveCleanButton, 'CallbackProperties');
set(hEvokedCleanButton, 'ActionPerformedCallback', {@process_offline_average, mc, 'functional'});

% Generate custom average description
hCustomAveDesc = handle(GUI.CallbackInterface.customAverageDescription, 'CallbackProperties');
set(hCustomAveDesc, 'ActionPerformedCallback', {@configure_ave, mc});

% Generate evoked with clean data and custom average description
hCustomAveButton = handle(GUI.CallbackInterface.customAverageButton, 'CallbackProperties');
set(hCustomAveButton, 'ActionPerformedCallback', {@process_offline_average, mc, 'custom'});

% Average events across runs
hAveRunsButton = handle(GUI.CallbackInterface.aveFunctionalRuns, 'CallbackProperties');
set(hAveRunsButton, 'ActionPerformedCallback', {@mc_clean_avefxnlruns, mc});

% Read fiff events
hGetFIFFevents = handle(GUI.CallbackInterface.getEventsFIFF, 'CallbackProperties');
set(hGetFIFFevents, 'ActionPerformedCallback', @get_FIFF_events);

% Get Protocols
hBstProtocols = handle(GUI.CallbackInterface.getBstProtocols, 'CallbackProperties');
set(hBstProtocols, 'ActionPerformedCallback', @get_bstProtocolList);

% Import DIP file into Brainstorm
hImportMEGButton = handle(GUI.CallbackInterface.bstImportDIPButton, 'CallbackProperties');
set(hImportMEGButton, 'ActionPerformedCallback', {@mc_bst_run_pipeline, 'ImportDIP', mc});

% Import MRI data into Brainstorm
hImportMRIButton = handle(GUI.CallbackInterface.bstImportMriButton, 'CallbackProperties');
set(hImportMRIButton, 'ActionPerformedCallback', {@mc_bst_run_pipeline, 'ImportMRI', mc});

% Run Brainstorm analysis pipelines
hPipelinePanelButton = handle(GUI.CallbackInterface.pipelinePanelButton, 'CallbackProperties');
set(hPipelinePanelButton, 'ActionPerformedCallback', {@configure_pipeline, mc});
hBatchBkgndButton = handle(GUI.CallbackInterface.batchRunBackgroundAnalysis, 'CallbackProperties');
set(hBatchBkgndButton, 'ActionPerformedCallback', {@mc_bst_run_pipeline, 'Background', mc});
hBatchInterictalButton = handle(GUI.CallbackInterface.batchRunSpikeAnalysis, 'CallbackProperties');
set(hBatchInterictalButton, 'ActionPerformedCallback', {@mc_bst_run_pipeline, 'Interictal', mc});
hBatchFunctionalButton = handle(GUI.CallbackInterface.batchRunFunctionalAnalysis, 'CallbackProperties');
set(hBatchFunctionalButton, 'ActionPerformedCallback', {@mc_bst_run_pipeline, 'Functional', mc});

% Render Images
hRenderMenuItem = handle(mc.getRenderMenuItem(), 'CallbackProperties');
set(hRenderMenuItem, 'ActionPerformedCallback', {@render_image, mc});

% Configure xfit command file
hCfitConfigButton = handle(GUI.CallbackInterface.configCfitButton, 'CallbackProperties');
set(hCfitConfigButton, 'ActionPerformedCallback', {@configure_cfit, mc});

% Run clean batch on selected data set
hCleanBatchButton = handle(GUI.CallbackInterface.runCleanBatchButton, 'CallbackProperties');
set(hCleanBatchButton, 'ActionPerformedCallback', {@process_batch_clean, mc});

% Merge selected dipole files
hMergeButton = handle(GUI.CallbackInterface.mergeDipFiles, 'CallbackProperties');
set(hMergeButton, 'ActionPerformedCallback', {@merge_dip_files});

end

%% Set Paths
function set_paths(type, homePath)
% set_paths: Add paths for use with MEG-Clinic
%
% USAGE:    set_paths('megclinic', homePath)    % Set paths to the MEG-Clinic source files
%           set_paths('apps')                   % Set paths to the MNE and Brainstorm applications
%
% INPUTS:   homePath = MEG-Clinic home directory
% -------------------------------------------------------------------------
switch (type)
    case 'megclinic'
        % source files
        addpath(homePath);
        addpath(strcat(homePath, '/config'));
        addpath(strcat(homePath, '/bst'));
        addpath(strcat(homePath, '/clean'));
        addpath(strcat(homePath, '/tools'));
        addpath(strcat(homePath, '/xfit'));

    case 'apps'       
        % MNE Toolbox
        addpath(char(GUI.DataSet.mneMatlabPath));

        % Brainstorm
        bstPath = char(GUI.DataSet.bstAppPath);
        addpath(bstPath);
        addpath(fullfile(bstPath, 'external/other'));
        addpath(fullfile(bstPath, 'toolbox/math'));
        addpath(fullfile(bstPath, 'toolbox/core'));
end
end

%% Exit Viewer
function exit_viewer(varargin)
% exit_viewer: callback function from MEG-Clinic, Exit Button
%
% USAGE:    set(exitButton, 'ActionPerformedCallback', {@exit_viewer, mc});
%           exit_viewer(mc)
%
% INPUT:   mc = MEG-Clinic instance
% -------------------------------------------------------------------------

if nargin > 2
    % This is the callback (obj = varargin{1}, event = varargin{2})
    mc = varargin{3};
else
    % This is direct usage
    mc = varargin{1};
end
% exit the Viewer and clear the java classes
disp('MEGClinic Stopped');    
awtinvoke(mc, 'dispose()');
clear java;
end

