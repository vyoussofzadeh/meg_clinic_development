function meg_clinic_exercise( varargin )
% meg_clinic_exercise: Exercise modules of MEG-Clinic
%
% USAGE:        meg_clinic_exercise('gui', rawDataPath, module)  
%               meg_clinic_exercise('gui', rawDataPath, module, email)  
%               
% INPUTS:       modules include ('acq', 'clean', 'usereve', 'mri', 'dipole',
%               'bst','report')
%
% Author: Elizabeth Bock, 2011
% --------------------------- Script History ------------------------------
% EB 27-Jan-2011    Creation
% -------------------------------------------------------------------------

%% ----- Setup MEG-Clinic environment
% Opengl software for use with Brainstorm
opengl software

% Get the megclinic homePath, assume we are in the megclinic folder
homePath = fileparts(fileparts(which(mfilename)));

% Java classes 
javaaddpath(strcat(homePath, '/java/MEGClinic1.0.jar'));

% Add BrainStorm JARs to classpath if setup is complete
if sum(strcmp(varargin,'setup')) == 0
    GUI.DataSet.initDataSet();
    bstPath = char(GUI.DataSet.bstAppPath);
    javaaddpath(strcat(bstPath,'/java/RiverLayout.jar'));
    javaaddpath(strcat(bstPath,'/java/brainstorm.jar'));
end

% Set the megclinic paths
set_paths('megclinic',homePath);

% Start a log file
logFile = GUI.MCLogFile;

%% ----- Start MEG-Clinic
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

if strcmp(varargin{3},'acq')    
    sssConfig = ArtifactClean.MaxFilterConfig();
    sssConfig.createCommand(sssConfig.SSS);
    rawPath = varargin{2};
    rawFiles = dir(fullfile(rawPath, '*_raw.fif'));
    command = sssConfig.getCommand(rawPath,rawFiles(1).name);
    


elseif strcmp(varargin{3},'clean')
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
    if length(varargin) > 3
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
end

%% Assign Callbacks
function assignCallbacks(mc)
% assignCallbacks: Assign the button callbacks to the MEG-Clinic GUI
%
% INPUTS:   mc = instance of MEG-Clinic
% -------------------------------------------------------------------------

% Brainstorm
bstButton = GUI.CallbackInterface.startBrainstorm;
set(bstButton, 'ActionPerformedCallback',{@brainstorm_callback, 'start'});

% Button Exit
exitButton = GUI.CallbackInterface.exitButton;
set(exitButton, 'ActionPerformedCallback', {@exit_viewer, mc});

% Remove Artifacts
cfArtifactsButton = GUI.CallbackInterface.artifactCleanButton;
set(cfArtifactsButton, 'ActionPerformedCallback', {@process_auto_clean, mc});

% Create xfit inputs for dipole fitting
cfitButton = GUI.CallbackInterface.writeCfitButton;
set(cfitButton, 'ActionPerformedCallback', {@process_xfit_input, mc});

% Generate evoked with clean data
evokedCleanButton = GUI.CallbackInterface.genAveCleanButton;
set(evokedCleanButton, 'ActionPerformedCallback', {@process_offline_average, mc, 'functional'});

% Generate evoked with clean data and custom average description
customAveButton = GUI.CallbackInterface.customAverageButton;
set(customAveButton, 'ActionPerformedCallback', {@process_offline_average, mc, 'custom'});

% Get Protocols
bstProtocols = GUI.CallbackInterface.getBstProtocols;
set(bstProtocols, 'ActionPerformedCallback', @get_bstProtocolList);

% Import MEG data into Brainstorm
importMEGButton = GUI.CallbackInterface.bstImportMegButton;
set(importMEGButton, 'ActionPerformedCallback', {@brainstorm_runProcess, 'ImportMEG', mc});

% Import MRI data into Brainstorm
importMRIButton = GUI.CallbackInterface.bstImportMriButton;
set(importMRIButton, 'ActionPerformedCallback', {@brainstorm_runProcess, 'ImportMRI', mc});

% Batch Brainstorm - generate a set of result images
batchBstButton = GUI.CallbackInterface.batchCreateImages;
set(batchBstButton, 'ActionPerformedCallback', {@brainstorm_runProcess, 'Batch', mc});

% Render Images
renderMenuItem = mc.getRenderMenuItem();
set(renderMenuItem, 'ActionPerformedCallback', {@render_image, mc});

% Configure xfit command file
cfitConfigButton = GUI.CallbackInterface.configCfitButton;
set(cfitConfigButton, 'ActionPerformedCallback', {@configure_cfit, mc});

% Run clean batch on selected data set
cleanBatchButton = GUI.CallbackInterface.runCleanBatchButton;
set(cleanBatchButton, 'ActionPerformedCallback', {@process_batch_clean, mc});

% Merge selected dipole files
mergeButton = GUI.CallbackInterface.mergeDipFiles;
set(mergeButton, 'ActionPerformedCallback', {@merge_dip_files});

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

