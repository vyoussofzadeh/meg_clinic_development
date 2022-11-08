function [iNoiseStudy, NoiseCovMat] = mc_bst_get_noisecov(iStudy, currentWorkflow)
% get_noiseCov_matrix: get the noise covariance matrix for a study
%
% USAGE:    NoiseCovMat = get_noiseCov_matrix(studyDir, subjectName, currentWorkflow)
%
% INPUT:    studyDir = study directory where the "empty room" study would be
%           subjectName = name of the subject
%           currentWorkflow = current workflow loaded by MEG-Clinic
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 10-May-2010    Creation
% EB 21-APRIL-2011  Updates for calling bst_noisecov automatically
% -------------------------------------------------------------------------

% Get emptyroom recording
emptyroomFile = char(currentWorkflow.getName(GUI.WorkflowConfig.EMPTYROOM));

% If emptyroom recording does not exist, use the default empty room
% recordings
if strcmp(emptyroomFile, '') 
    % Get the position
    position = char(currentWorkflow.getName(GUI.WorkflowConfig.PROBEPOSITION));
    % Default position is upright
    if strcmp(position, '')
        position = 'upright';
    end
    if strcmp(position, 'upright')
        emptyroomFile = char(GUI.DataSet.emptyUprightFile);
    else
        emptyroomFile = char(GUI.DataSet.emptySupineFile);
    end
end
% Find the bst study
[~, name] = fileparts(emptyroomFile);
sSubject = bst_get('Subject');
NoiseStudy = bst_get('Study', file_fullpath(fullfile(sSubject.Name, name, 'brainstormstudy.mat')));
% Open FIF file, to get time window
ImportOptions = db_template('ImportOptions');
ImportOptions.DisplayMessages = 0;
ImportOptions.EventsMode = 'ignore';
sFile = in_fopen_fif(emptyroomFile,ImportOptions); 
timewindow(1) = double(floor(sFile.header.raw.first_samp/sFile.header.info.sfreq));
timewindow(2) = double(ceil(sFile.header.raw.last_samp/sFile.header.info.sfreq));
% If the brainstorm study does not exist, create link to raw file
if isempty(NoiseStudy)
    sFiles = [];
    % Process: Create link to raw file
    sFiles = bst_process('CallProcess', 'process_import_data_raw', ...
        sFiles, [], ...
        'subjectname', sSubject.Name, ...
        'datafile', {emptyroomFile, 'FIF'}, ...
        'channelreplace', 1, ...
        'channelalign', 0);

    % Process: Compute noise covariance
    noiseFiles = bst_process('CallProcess', 'process_noisecov', ...
        sFiles, [], ...
        'baseline', timewindow, ...
        'target', 1, ...
        'dcoffset', 1, ...
        'method', 1, ...  % Full noise covariance matrix
        'copycond', 0, ...
        'copysubj', 0);
    
    iNoiseStudy = unique([noiseFiles.iStudy]); 
    NoiseStudy = bst_get('Study', iNoiseStudy);
end
NoiseCovMat = load(file_fullpath(NoiseStudy.NoiseCov.FileName));