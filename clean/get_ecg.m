function [ecg, channelType] = get_ecg(fiffsetup)
% GET_ECG: Extract ECG from raw file
%
% USAGE:    ecg = get_ecg(fiffsetup);
%
% INPUT:    fiffsetup = fiff file info structure (mne)
%
% OUTPUT:   ecg = channel signal containing ecg information
%           channelType = 0, ECG channel
%           channelType = 1, MEG channel
%
% Author: Elizabeth Bock, 2009
% --------------------------- Script History ------------------------------
% EB 27-AUG-2009  Creation
% -------------------------------------------------------------------------

config = upper(char(ArtifactClean.CleanConfig.ECG_CHAN));

% ----------------------- Determine Channel for ECG information -----------
if strcmp(config, 'AUTO') || strcmp(config, '')
    channel = 'ECG';
    channelType = 0; % this is default for ECG channel
else
    channel = config;
    channelType = 1;
end


channelNames = fiffsetup.info.ch_names;
ch_ECG = strmatch(channel,channelNames);

if isempty(ch_ECG) % ECG channel does not exist
    [ch_ECG,okButton] = listdlg('Name', 'No ECG Channel', 'PromptString', 'Select Another Channel?:',...
                'SelectionMode','single',...
                'ListString',channelNames); % prompt user to choose an MEG channel
    if okButton
        channelType = 1; % MEG channel choosen for analysis
    else
        GUI.ErrorMessage(GUI.ErrorMessage.GENERIC_ERROR, 'No ECG Channel Available for Cleaning.');
        ecg = [];
        return;
    end
end

% ------------------ Get channel signal from raw file ---------------------
start_samp = fiffsetup.first_samp;
end_samp = fiffsetup.last_samp;
[ecg,ecgtimes] = fiff_read_raw_segment(fiffsetup, start_samp ,end_samp, ch_ECG);
