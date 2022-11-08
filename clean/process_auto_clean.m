function [FileNames, mask, stimSource] = process_auto_clean(varargin)
% process_auto_clean: callback function from MEG-Clinic, Remove ECG Artifact Button
%
% USAGE:    set(cfArtifactsButton, 'ActionPerformedCallback', {@process_auto_clean, mc});
%           process_auto_clean(mc)
%
% INPUT:   mc = MEG-Clinic instance
%
% Author: Elizabeth Bock, 2009
% --------------------------- Script History ------------------------------
% EB 27-AUG-2009    Creation
% EB 25-MAY-2010    Updates for callback
% -------------------------------------------------------------------------

if nargin > 2
    % This is the callback (obj = varargin{1}, event = varargin{2})
    mc = varargin{3};
else
    % This is direct usage
    mc = varargin{1};
end

logFile = GUI.MCLogFile;
FileNames = [];
mask = [];
stimSource=[];

%% Get selected file info
mc.setMessage(GUI.Config.M_READ_DATA_FILE);
try
    filename = char(mc.getInfo(GUI.Config.I_SELECTEDFILE));
catch
    GUI.ErrorMessage(GUI.ErrorMessage.WRONG_FILE_TYPE, 'SSS');
    return
end

% Selected file must an 'sss' file
index1 = strfind(filename,'_sss');
index2 = strfind(filename, '_tsss');
index3 = strfind(filename, '_cHPIsss');

if isempty(index1) && isempty(index2) && isempty(index3)
    GUI.ErrorMessage(GUI.ErrorMessage.WRONG_FILE_TYPE, 'SSS');
    return
end

filelocation = char(mc.getInfo(GUI.Config.I_FILE_LOCATION));
if strcmp(filelocation, 'null')
    GUI.ErrorMessage(GUI.ErrorMessage.FILE_LOCATION_NOT_FOUND, '');
    return
end

% Read configuration info
FileNames = create_default_file_names(filename);
FileNames.filelocation = filelocation;

% Find fxnl data
wf = GUI.DataSet.currentWorkflow;
FileNames.aveName = char(wf.getName(GUI.WorkflowConfig.AVESSS));
if strcmp(FileNames.aveName,'')
    % check for a raw ave file that has not been through sss
    files = dir(fullfile(char(GUI.DataSet.rawDataPath), FileNames.rawAveName));
    if isempty(files)
        FileNames = set_ave_description(FileNames, 'raw');
    else
        % ensure the STI channel gets preserved during the cleaning
        FileNames = set_ave_description(FileNames, 'functional');
    end
else
    FileNames = set_ave_description(FileNames, 'functional'); 
end

% Get workflow variables
mask = char(wf.getName(GUI.WorkflowConfig.MASK));
stimSource = char(wf.getName(GUI.WorkflowConfig.STIMSOURCE));

%% Apply filter to recording
filteredFile = [];
if ArtifactClean.CleanConfig.INCLUDE_FILTER
    filteredFile = create_filtered_file(mc, FileNames);
    FileNames = create_default_file_names(filteredFile);
    FileNames.filelocation = filelocation;
end

%% Calculate SSP for ongoing artifact then create cleaned version for
% additional artifact rejection
if ArtifactClean.CleanConfig.INCLUDE_ONGOING
    remove_ongoing_artifact(mc, FileNames);
    ogProjExist = exist(fullfile(FileNames.filelocation, FileNames.ogProjFileName), 'file');
    ogCleanExist = exist(fullfile(FileNames.filelocation, FileNames.ogCleanFileName), 'file');
    if ogProjExist && ~ogCleanExist
        % Apply projections and save to Clean file
        logFile.write('Applying projections');
        mc.setMessage(GUI.Config.M_APPLY_SSP);

        % Get workflow variables
        wf = GUI.DataSet.currentWorkflow;
        mask = char(wf.getName(GUI.WorkflowConfig.MASK));
        stimSource = char(wf.getName(GUI.WorkflowConfig.STIMSOURCE));
        command = ['mne_process_raw --cd ' FileNames.filelocation ' --raw ' FileNames.filename ' --proj ' FileNames.ogProjFileName ' --projon --save ' FileNames.ogCleanFileName ' --digtrig ' stimSource ' --digtrigmask ' mask ' --filteroff'];
        logFile.write(['command: ' command]);
        [s, w] = unix(command);
        logFile.write(w);
        if s
            GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_WARNING, [fullfile(FileNames.filelocation, FileNames.ogCleanFileName) ' was not created.']);
        else
            FileNames = create_default_file_names(fullfile(FileNames.filelocation,FileNames.ogCleanFileName));
            FileNames.filelocation = filelocation;
        end
    else
        GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_WARNING, [fullfile(FileNames.filelocation, FileNames.ogProjFileName) ' does not exist. These projections will not be applied']);
    end
end
finalCleanName = [];

%% Calculate SSP for ECG artifact
if ArtifactClean.CleanConfig.INCLUDE_ECG
    remove_ecg_artifact(mc, FileNames);
end

%% Calculate SSP for EOG artifact
if ArtifactClean.CleanConfig.INCLUDE_EOG
    remove_eog_artifact(mc, FileNames);
end

%% Generate clean
cleanFile = fullfile(FileNames.filelocation, FileNames.cleanFileName);
if ~exist(cleanFile,'file')
    appliedProj = {};
    if ArtifactClean.CleanConfig.INCLUDE_ECG
        ecgProjExist = exist(fullfile(FileNames.filelocation, FileNames.ecgProjFileName),'file');
        if ecgProjExist 
           appliedProj{length(appliedProj)+1} = FileNames.ecgProjFileName; % Include ecg proj
           finalCleanName = FileNames.ecgCleanFileName;
        end
    end
    if ArtifactClean.CleanConfig.INCLUDE_EOG
        eogProjExist = exist(fullfile(FileNames.filelocation, FileNames.eogProjFileName), 'file');
        if eogProjExist
            appliedProj{length(appliedProj)+1} = FileNames.eogProjFileName; % Include eog proj
            finalCleanName = FileNames.eogCleanFileName;
        end
    end    

    % List the projections to include
    projString = '';
    for i=1:length(appliedProj)
        projString = [projString ' --proj ' char(appliedProj(i))];
    end

    if length(appliedProj) > 1
        % the xtra clean name is defined above if only one proj exists.  If
        % two exist, then use the user defined clean name.
        finalCleanName = FileNames.cleanFileName;
    end

    if ~isempty(finalCleanName)
        % Apply projections and save to Clean file
        logFile.write('Applying projections');
        mc.setMessage(GUI.Config.M_APPLY_SSP);

        % Get workflow variables
        wf = GUI.DataSet.currentWorkflow;
        mask = char(wf.getName(GUI.WorkflowConfig.MASK));
        stimSource = char(wf.getName(GUI.WorkflowConfig.STIMSOURCE));
        command = ['mne_process_raw --cd ' FileNames.filelocation ' --raw ' FileNames.filename projString ' --projon --save ' finalCleanName ' --digtrig ' stimSource ' --digtrigmask ' mask ' --filteroff'];
        logFile.write(['command: ' command]);
        [s, w] = unix(command);
        logFile.write(w);
        if s
            GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_WARNING, [fullfile(FileNames.filelocation, FileNames.ogCleanFileName) ' was not created.']);
        else
            % Clean up extra files
            ogClean = fullfile(FileNames.filelocation, FileNames.ogCleanFileName);
            if exist(ogClean,'file')
                [p,n,e] = fileparts(ogClean);    
                delete(ogClean)
                logFile.write(['delete' ogClean]);
                delete(fullfile(p,[n '-eve' e]))
                logFile.write(['delete' fullfile(p,[n '-eve' e])]);            
            end
        end
    end
end

%% Clean up extra files
if ~isempty(filteredFile)
%    delete(filteredFile);
end

%% Refresh the database tree
mc.setMessage(GUI.Config.M_CLEAN_RAW_WRITTEN);
mc.refreshSelectedTreeNode();
mc.refreshSelectedWorkflow(mc.getCurrentWorkflow());