function name = mc_bst_importdipoles(selectedPaths)
% mc_bst_importdipoles: Import dipole file into brainstorm
%
% USAGE:    mc_bst_importdipoles(selectedPaths)
%
% INPUT:
%           selectedPaths = ArrayList<String> of two selected paths from the
%           database tree - One original file and One dipole file
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 24-MAY-2010    Creation
% EB 11-APR-2011    Import raw data to create a study if study does not
% exist.  This allows users to import dipoles before importing and
% analyzing the raw data.
% -------------------------------------------------------------------------

clear global FIFF

nFiles = selectedPaths.size;
if nFiles < 2
    errorString = sprintf('%s\n%s\n%s','You must select at least 2 files:', '1). dipole file','2). corresponding raw or ave file');
    GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_ERROR, errorString);
    return
end

nDip = 0;
nOrig = 0;
for ii = 0:nFiles-1 % Java uses zero indexing
    if findstr(char(selectedPaths.get(ii)), '.bdip')
        nDip = nDip+1;
        dipFile{nDip} = char(selectedPaths.get(ii));
    elseif findstr(char(selectedPaths.get(ii)), '.fif')
        nOrig = nOrig+1;
        origFile{nOrig} = char(selectedPaths.get(ii));
    else
        GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_ERROR, 'Unknown file type selected');
        return
    end
end

if nOrig > 1
    errorString = sprintf('%s\n%s\n%s','Only one raw or average FIFF file should be selected.');
    GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_ERROR, errorString);
    return
end

% Get the message area
messages = GUI.CallbackInterface.messageTextArea;

% Get the data file name
[path, fileName] = fileparts(origFile{1});
sProtocol = bst_get('ProtocolInfo');
studyDir = sProtocol.STUDIES; 
[sSubject,iSubject] = bst_get('Subject',char(GUI.DataSet.subject));
subjectName = sSubject.Name;
DataFile = fullfile(studyDir, subjectName, fileName, 'brainstormstudy.mat');
[sStudy, iStudy] = bst_get('Study', DataFile);

% If the study does not exist, import the raw data to create the study
if isempty(sStudy)
    % Open FIFF file
    selectedFile = origFile{1};
    FileNamesA = [];
    FileNamesB = [];
    
    % import options for evoked files
    if findstr(selectedFile, '_ave.fif')
        % -----Import events
        % Process: Import MEG/EEG: Epochs
        sFiles = bst_process(...
            'CallProcess', 'process_import_data_epoch', ...
            FileNamesA, FileNamesB, ...
            'datafile', {dataFile, 'FIF', 'open', 'Import EEG/MEG recordings...', 'ImportData', 'multiple', 'files_and_dirs', {{'.meg4', '.res4'}, 'MEG/EEG: CTF (*.ds;*.meg4;*.res4)', 'CTF'; {'.fif'}, 'MEG/EEG: Neuromag FIFF (*.fif)', 'FIF'; {'.*'}, 'MEG/EEG: 4D-Neuroimaging/BTi (*.*)', '4D'; {'.lena', '.header'}, 'MEG/EEG: LENA (*.lena)', 'LENA'; {'.cnt'}, 'EEG: ANT EEProbe (*.cnt)', 'EEG-ANT-CNT'; {'.eeg'}, 'EEG: BrainVision BrainAmp (*.eeg)', 'EEG-BRAINAMP'; {'.edf', '.rec'}, 'EEG: EDF / EDF+ (*.rec;*.edf)', 'EEG-EDF'; {'.set'}, 'EEG: EEGLAB (*.set)', 'EEG-EEGLAB'; {'.raw'}, 'EEG: EGI Netstation RAW (*.raw)', 'EEG-EGI-RAW'; {'.cnt', '.avg', '.eeg'}, 'EEG: Neuroscan (*.cnt;*.eeg;*.avg)', 'EEG-NEUROSCAN'; {'.mat'}, 'NIRS: MFIP (*.mat)', 'NIRS-MFIP'}, 'DataIn'}, ...
            'subjectname', 'sample_set2', ...
            'condition', '', ...
            'iepochs', '', ...
            'createcond', 0, ...
            'channelalign', 1, ...
            'usectfcomp', 1, ...
            'usessp', 1);

    
    % import options for raw files
    else 
        % Process: Import MEG/EEG: Time
        sFiles = bst_process(...
            'CallProcess', 'process_import_data_time', ...
            FileNamesA, FileNamesB, ...
            'datafile', {{selectedFile}, 'FIF', 'open', 'Import EEG/MEG recordings...', 'ImportData', 'multiple', 'files_and_dirs', {{'.meg4', '.res4'}, 'MEG/EEG: CTF (*.ds;*.meg4;*.res4)', 'CTF'; {'.fif'}, 'MEG/EEG: Neuromag FIFF (*.fif)', 'FIF'; {'.*'}, 'MEG/EEG: 4D-Neuroimaging/BTi (*.*)', '4D'; {'.lena', '.header'}, 'MEG/EEG: LENA (*.lena)', 'LENA'; {'.cnt'}, 'EEG: ANT EEProbe (*.cnt)', 'EEG-ANT-CNT'; {'.eeg'}, 'EEG: BrainVision BrainAmp (*.eeg)', 'EEG-BRAINAMP'; {'.edf', '.rec'}, 'EEG: EDF / EDF+ (*.rec;*.edf)', 'EEG-EDF'; {'.set'}, 'EEG: EEGLAB (*.set)', 'EEG-EEGLAB'; {'.raw'}, 'EEG: EGI Netstation RAW (*.raw)', 'EEG-EGI-RAW'; {'.cnt', '.avg', '.eeg'}, 'EEG: Neuroscan (*.cnt;*.eeg;*.avg)', 'EEG-NEUROSCAN'; {'.mat'}, 'NIRS: MFIP (*.mat)', 'NIRS-MFIP'}, 'DataIn'}, ...
            'subjectname', 'sample_set2', ...
            'condition', '', ...
            'timewindow', [10.5, 55.4995], ...
            'split', 2, ...
            'channelalign', 1, ...
            'usectfcomp', 1, ...
            'usessp', 1);
    end

end

% Import dipoles
[sStudy, iStudy] = bst_get('Study', DataFile);
for jj = 1:nDip
    [path, name] = fileparts(dipFile{jj});
    messages.setText(['Brainstorm - Import Dipoles: ' name]);
    import_dipoles(iStudy, [], dipFile{jj});
end
messages.setText('Done');