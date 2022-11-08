function iStudies = mc_bst_import_rawchunks(varargin)
% mc_bst_import_rawchunks: import raw data into brainstorm db 
%
% USAGE:    mc_bst_import_rawchunks(rawFiles)
%           mc_bst_import_rawchunks(rawFiles, nChunks)
%           
% INPUT:    rawFiles = cell array of strings containing full path to raw files (typically *_xtraClean_raw.fif)
%           nChunks = number of (2 sec) chunks in import
%
% Author: Elizabeth Bock, 2011
% --------------------------- Script History ------------------------------
% EB 12-JULY-2011 Creation
% -------------------------------------------------------------------------
%% Inputs
rawFiles = varargin{1};

if nargin > 1
    nChunks = double(varargin{2});
else
    nChunks = [];
end

% Keep track of the studies that are updated/created
iStudies = [];
%% Import
for i=1:length(rawFiles)
    % -----Get corresponding "study" name
    selectedFile = rawFiles{i};
    [path, fileName] = fileparts(selectedFile);
    sProtocol = bst_get('ProtocolInfo');
    studyDir = sProtocol.STUDIES;
    subjectName = char(GUI.DataSet.subject);
    [sSubject, iSubject] = bst_get('Subject',subjectName);
    subjectName = sSubject.Name;
    currentStudyName = fullfile(studyDir, subjectName, fileName, 'brainstormstudy.mat');
    % Check for raw segments already imported
    [sStudy, iStudy]=bst_get('Study', currentStudyName);
    dataIndices = [];
    if ~isempty(sStudy)
        pat='Raw';
        ind = strfind({sStudy.Data.Comment}, pat);
        dataIndices = find(~cellfun(@isempty, ind));
    end

    if isempty(sStudy) || isempty(dataIndices)    
        % -----Import Raw Chunks
        ImportOptions = db_template('ImportOptions');
        ImportOptions.ImportMode = 'time';
        ImportOptions.CreateConditions = 0;
        ImportOptions.DisplayMessages = 0;
        ImportOptions.EventsMode = 'ignore';
        % Open FIF file, to get time window
        sFile = in_fopen_fif(selectedFile,ImportOptions); 
        timewindow(1) = floor(sFile.header.raw.first_samp/sFile.header.info.sfreq);
        timewindow(2) = ceil(sFile.header.raw.last_samp/sFile.header.info.sfreq);
        splitLength = 2;
        
        % if nChunks is defined, only import that amount of time
        if ~isempty(nChunks)
            timewindow(2) = nChunks*2;
        end

        FileNamesA = [];
        FileNamesB = [];
        % Process: Import MEG/EEG: Time
        sFiles = bst_process(...
            'CallProcess', 'process_import_data_time', ...
            FileNamesA, FileNamesB, ...
            'datafile', {{selectedFile}, 'FIF', 'open', 'Import EEG/MEG recordings...', 'ImportData', 'multiple', 'files_and_dirs', {{'.meg4', '.res4'}, 'MEG/EEG: CTF (*.ds;*.meg4;*.res4)', 'CTF'; {'.fif'}, 'MEG/EEG: Neuromag FIFF (*.fif)', 'FIF'; {'.*'}, 'MEG/EEG: 4D-Neuroimaging/BTi (*.*)', '4D'; {'.lena', '.header'}, 'MEG/EEG: LENA (*.lena)', 'LENA'; {'.cnt'}, 'EEG: ANT EEProbe (*.cnt)', 'EEG-ANT-CNT'; {'.eeg'}, 'EEG: BrainVision BrainAmp (*.eeg)', 'EEG-BRAINAMP'; {'.edf', '.rec'}, 'EEG: EDF / EDF+ (*.rec;*.edf)', 'EEG-EDF'; {'.set'}, 'EEG: EEGLAB (*.set)', 'EEG-EEGLAB'; {'.raw'}, 'EEG: EGI Netstation RAW (*.raw)', 'EEG-EGI-RAW'; {'.cnt', '.avg', '.eeg'}, 'EEG: Neuroscan (*.cnt;*.eeg;*.avg)', 'EEG-NEUROSCAN'; {'.mat'}, 'NIRS: MFIP (*.mat)', 'NIRS-MFIP'}, 'DataIn'}, ...
            'subjectname', subjectName, ...
            'condition', '', ...
            'timewindow', timewindow, ...
            'split', splitLength, ...
            'channelalign', 1, ...
            'usectfcomp', 1, ...
            'usessp', 1);

    end
    % Keep track of the studies represented by the raw files
    [sStudy, iStudy]=bst_get('Study', currentStudyName);
    iStudies = [iStudies iStudy];
end