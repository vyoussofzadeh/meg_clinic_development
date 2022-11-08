function process_offline_average(varargin)
% process_offline_average: callback function from MEG-Clinic, Average Clean
% Data
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
    type = varargin{4};
else
    % This is direct usage
    mc = varargin{1};
    type = varargin{2};
end


%% ------------- Get Clean file Name ---------------------------------------
mc.setMessage(GUI.Config.M_READ_DATA_FILE);
cleanFile = char(mc.getInfo(GUI.Config.I_SELECTEDFILE));
if strcmp(cleanFile,'null')
    return
end
if isempty(strfind(cleanFile, '_raw.fif')) && isempty(strfind(cleanFile, '_sss.fif'))
    error('Select a clean raw file')
end

filelocation = char(mc.getInfo(GUI.Config.I_FILE_LOCATION));
if strcmp(filelocation, 'null')
    return
end

filename = cleanFile;

% ------------- Get default file names ------------------------------------
FileNames = create_default_file_names(filename);
FileNames.filelocation = filelocation;

% Use the selected file as the clean file
[p,n,e] = fileparts(cleanFile);
FileNames.cleanFileName = [n e];
% Update average and log file names for the ave description file
FileNames.cleanAveFileName = regexprep([n e], '_raw.fif', '_ave.fif');
FileNames.logAveFileName = regexprep([n e], '_raw.fif', '_ave.log');

%% ------------- Find ave description -------------------------------------
FileNames = set_ave_description(FileNames, type);

%% ------------ Clean ave -------------------------------------------------
mc.setMessage(GUI.Config.M_MAKE_CLEAN_AVE);
% Get the workflow variables
wf = mc.getCurrentWorkflow();
mask = char(wf.getName(GUI.WorkflowConfig.MASK));
stimSource = char(wf.getName(GUI.WorkflowConfig.STIMSOURCE));
% Generate evoked clean
status = generate_evoked_clean(FileNames, mask, stimSource);
if status
    GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_WARNING, 'Clean average file not written');
else
    mc.setMessage(GUI.Config.M_CLEAN_AVE_WRITTEN);
end

% Give notice to the user
mc.setMessage(GUI.Config.M_DONE);
mc.refreshSelectedTreeNode();
mc.refreshSelectedWorkflow(mc.getCurrentWorkflow());