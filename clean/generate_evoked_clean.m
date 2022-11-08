function status = generate_evoked_clean(FileNames, mask, stimSource)
% generate_evoked_clean: offline average of clean data
%
% USAGE: status = generate_evoked_clean(FileNames, mask, stimSource)
%
% INPUT:    FileNames = FileNames structure
%           mask = digtrigmask for mne_process_raw
%           stimSource = digtrig for mne_process_raw
%
% OUTPUT:   status = 0, no errors
%           status = 1, errors
%
% Author: Elizabeth Bock, 2009
% --------------------------- File History --------------------------------
% EB 27-AUG-2009  Creation
% -------------------------------------------------------------------------

logFile = GUI.MCLogFile;

% ------------- Check for existing files ----------------------------------
aveCleanExist = exist(fullfile(FileNames.filelocation, FileNames.cleanAveFileName), 'file');

if aveCleanExist
    GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_WARNING, 'The average clean file already exists.');
    status = 0;
    return
end

% Creates an ECG-cleaned average file for functional protocol data
disp('Generating evoked clean...')

command = ['mne_process_raw --cd ' FileNames.filelocation ' --raw ' FileNames.cleanFileName ' --ave  ' FileNames.aveDescriptionFile ' --projon --digtrig ' stimSource ' --digtrigmask ' mask];
logFile.write(['command: ' command]);
[status, w] = unix(command);
logFile.write(w);
%disp(w)
