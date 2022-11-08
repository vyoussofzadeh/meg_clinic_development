function eog = get_eog(fiffsetup)
% GET_ECG: Extract EOG from raw file
%
% USAGE:    eog = get_eog(fiffsetup);
%
% INPUT:    fiffsetup = fiff file info structure (mne)
%
% OUTPUT:   eog = channel signal containing ecg information
%
% Author: Elizabeth Bock, 2010
% --------------------------- Script History ------------------------------
% EB 18-NOV-2010  Creation
% -------------------------------------------------------------------------
config = upper(char(ArtifactClean.CleanConfig.EOG_CHAN));

% ----------------------- Determine Channel for ECG information -----------
if strcmp(config, 'AUTO') || strcmp(config, '')
    channel = 'EOG';
    channelType = 0;
else
    channel = config;
    channelType = 1; %MEG or EEG Channel choosen
end

channelNames = fiffsetup.info.ch_names;
ch_EOG = strmatch(channel,channelNames);

if isempty(ch_EOG) % ECG channel does not exist
    [ch_EOG,okButton] = listdlg('Name', 'No EOG Channel', 'PromptString', 'Select Another Channel?:',...
                'SelectionMode','single',...
                'ListString',channelNames); % prompt user to choose an MEG channel
    if okButton
        channelType = 1; % MEG or EEG channel choosen for analysis
    else
        GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_ERROR, 'No EOG Channel Available for Cleaning.');
        eog = [];
        return;
    end
end

% ------------------ Get channel signal from raw file ---------------------
start_samp = fiffsetup.first_samp;
end_samp = fiffsetup.last_samp;
eog = fiff_read_raw_segment(fiffsetup, start_samp ,end_samp, ch_EOG);
